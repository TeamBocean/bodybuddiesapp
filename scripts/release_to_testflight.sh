#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
IOS_DIR="$APP_DIR/ios"
ENV_FILE="${RELEASE_ENV_FILE:-$APP_DIR/.env}"
IPA_PATH="${TESTFLIGHT_IPA_PATH:-}"
DRY_RUN=0
SKIP_BUILD=0
UNSIGNED=0

usage() {
  cat <<'EOF'
Build and upload the iOS IPA to TestFlight.

Usage:
  ./scripts/release_to_testflight.sh [options]

Options:
  --ipa <path>    Upload an existing IPA (implies --skip-build)
  --skip-build    Require --ipa and skip validation/build
  --unsigned      Build an unsigned release app for validation (never uploads)
  --dry-run       Build and validate the IPA but do not upload
  -h, --help      Show this help

Environment:
  RELEASE_ENV_FILE      Public runtime config file (default: .env)
  PAYMENT_MODE          live or test/sandbox (default: test)
  TESTFLIGHT_IPA_PATH   Existing IPA path

Only public client configuration is read from RELEASE_ENV_FILE. Email and
service-account credentials are never passed to the Flutter build.
EOF
}

die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

log() {
  printf '%s\n' "$*"
}

read_env_value() {
  local key="$1"
  local file="$2"
  local line value

  [[ -f "$file" ]] || return 0
  line="$(sed -n "s/^${key}=//p" "$file" | tail -n 1)"
  value="${line%$'\r'}"
  if [[ "$value" == \"*\" && "$value" == *\" ]]; then
    value="${value:1:${#value}-2}"
  elif [[ "$value" == \'*\' && "$value" == *\' ]]; then
    value="${value:1:${#value}-2}"
  fi
  printf '%s' "$value"
}

public_config_value() {
  local key="$1"
  local current_value="${!key:-}"

  if [[ -n "$current_value" ]]; then
    printf '%s' "$current_value"
  else
    read_env_value "$key" "$ENV_FILE"
  fi
}

while (($# > 0)); do
  case "$1" in
    --ipa)
      (($# >= 2)) || die "--ipa requires a path"
      IPA_PATH="$2"
      SKIP_BUILD=1
      shift 2
      ;;
    --skip-build)
      SKIP_BUILD=1
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --unsigned)
      UNSIGNED=1
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "Unknown option '$1'. Use --help for usage."
      ;;
  esac
done

if [[ "$SKIP_BUILD" == 1 && -z "$IPA_PATH" ]]; then
  die "--skip-build requires --ipa <path>."
fi

if [[ "$SKIP_BUILD" == 0 ]]; then
  command -v flutter >/dev/null 2>&1 || die "Flutter was not found on PATH."
  PAYMENT_MODE_VALUE="${PAYMENT_MODE:-test}"
  PAYMENT_MODE_NORMALIZED="$(printf '%s' "$PAYMENT_MODE_VALUE" | tr '[:upper:]' '[:lower:]')"
  case "$PAYMENT_MODE_NORMALIZED" in
    live|test|sandbox) ;;
    *) die "PAYMENT_MODE must be live, test, or sandbox." ;;
  esac

  STRIPE_PUBLISHABLE_KEY_VALUE="$(public_config_value STRIPE_PUBLISHABLE_KEY)"
  STRIPE_TEST_PUBLISHABLE_KEY_VALUE="$(public_config_value STRIPE_TEST_PUBLISHABLE_KEY)"
  PAYMENT_INTENT_ENDPOINT_VALUE="$(public_config_value PAYMENT_INTENT_ENDPOINT)"
  PAYMENT_INTENT_TEST_ENDPOINT_VALUE="$(public_config_value PAYMENT_INTENT_TEST_ENDPOINT)"
  BOOKING_COMMAND_ENDPOINT_VALUE="$(public_config_value BOOKING_COMMAND_ENDPOINT)"

  if [[ "$PAYMENT_MODE_NORMALIZED" == live ]]; then
    [[ "$STRIPE_PUBLISHABLE_KEY_VALUE" == pk_live_* ]] ||
      die "Live builds require STRIPE_PUBLISHABLE_KEY beginning with pk_live_."
    [[ -n "$PAYMENT_INTENT_ENDPOINT_VALUE" ]] ||
      die "Live builds require PAYMENT_INTENT_ENDPOINT."
  else
    [[ "$STRIPE_TEST_PUBLISHABLE_KEY_VALUE" == pk_test_* ]] ||
      die "Test builds require STRIPE_TEST_PUBLISHABLE_KEY beginning with pk_test_."
    [[ -n "$PAYMENT_INTENT_TEST_ENDPOINT_VALUE" ]] ||
      die "Test builds require PAYMENT_INTENT_TEST_ENDPOINT."
  fi

  DART_DEFINE_ARGS=(
    "--dart-define=PAYMENT_MODE=$PAYMENT_MODE_VALUE"
    "--dart-define=STRIPE_PUBLISHABLE_KEY=$STRIPE_PUBLISHABLE_KEY_VALUE"
    "--dart-define=STRIPE_TEST_PUBLISHABLE_KEY=$STRIPE_TEST_PUBLISHABLE_KEY_VALUE"
    "--dart-define=PAYMENT_INTENT_ENDPOINT=$PAYMENT_INTENT_ENDPOINT_VALUE"
    "--dart-define=PAYMENT_INTENT_TEST_ENDPOINT=$PAYMENT_INTENT_TEST_ENDPOINT_VALUE"
  )
  if [[ -n "$BOOKING_COMMAND_ENDPOINT_VALUE" ]]; then
    DART_DEFINE_ARGS+=(
      "--dart-define=BOOKING_COMMAND_ENDPOINT=$BOOKING_COMMAND_ENDPOINT_VALUE"
    )
  fi

  log "Running static analysis and tests before release..."
  (
    cd "$APP_DIR"
    flutter analyze --no-fatal-infos --no-fatal-warnings
    flutter test
  )
  if [[ -d "$APP_DIR/../functions/node_modules" ]]; then
    npm --prefix "$APP_DIR/../functions" run lint
    npm --prefix "$APP_DIR/../functions" run build
  else
    die "Firebase Functions dependencies are missing. Run npm ci in functions/."
  fi

  if [[ "$UNSIGNED" == 1 ]]; then
    log "Building unsigned iOS release app for validation..."
    (
      cd "$APP_DIR"
      flutter build ios --release --no-codesign "${DART_DEFINE_ARGS[@]}"
    )
    IPA_PATH="$APP_DIR/build/ios/iphoneos/Runner.app"
  else
    log "Building signed TestFlight IPA..."
    (
      cd "$APP_DIR"
      flutter build ipa --release "${DART_DEFINE_ARGS[@]}"
    )
    IPA_PATH="$(find "$APP_DIR/build/ios/ipa" -maxdepth 1 -name '*.ipa' -print -quit)"
  fi
elif [[ "$IPA_PATH" != /* ]]; then
  IPA_PATH="$APP_DIR/$IPA_PATH"
fi

if [[ "$UNSIGNED" == 1 ]]; then
  [[ -d "$IPA_PATH" ]] || die "Unsigned app not found at '$IPA_PATH'."
  log "Unsigned release app ready: $IPA_PATH"
else
  [[ -f "$IPA_PATH" ]] || die "IPA not found at '$IPA_PATH'."
  [[ -s "$IPA_PATH" ]] || die "IPA is empty at '$IPA_PATH'."
  log "IPA ready: $IPA_PATH"
fi

if [[ "$DRY_RUN" == 1 ]]; then
  log "Dry run complete; nothing was uploaded."
  exit 0
fi

command -v bundle >/dev/null 2>&1 || die "Bundler was not found on PATH."
(
  cd "$IOS_DIR"
  bundle check >/dev/null 2>&1 ||
    die "Fastlane gems are missing. Run 'bundle install' in $IOS_DIR."
  bundle exec fastlane ios upload_ipa ipa_path:"$IPA_PATH"
)

log "TestFlight upload finished."
