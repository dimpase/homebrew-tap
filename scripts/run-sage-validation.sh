#!/usr/bin/env bash
set -euo pipefail

: "${VALIDATION_ROOT:?Set VALIDATION_ROOT to the isolated validation directory}"
script_dir=$(cd "$(dirname "$0")" && pwd)
brew_prefix=$(brew --prefix)
unset PYTHONPATH PYTHONHOME SAGE_ROOT SAGE_LOCAL SAGE_VENV SAGE_LIB SAGE_SRC SAGE_SHARE SAGE_DATA_PATH
# shellcheck disable=SC1091
source "${VALIDATION_ROOT}/venv/bin/activate"
: "${VIRTUAL_ENV:?Virtual environment activation must set VIRTUAL_ENV}"
# shellcheck disable=SC1091
source "${brew_prefix}/opt/sagemath-deps/share/sagemath-deps/python3.14-env.sh"
export DOT_SAGE="${VALIDATION_ROOT}/dot-sage"
export MAXIMA_OBJDIR="${VALIDATION_ROOT}/maxima-cache"
export MPLCONFIGDIR="${VALIDATION_ROOT}/matplotlib"
export MPLBACKEND=Agg PYTHONNOUSERSITE=1
export SAGE_NUM_THREADS=2 OMP_NUM_THREADS=2 OPENBLAS_NUM_THREADS=2 VECLIB_MAXIMUM_THREADS=2
export UV_CONCURRENT_BUILDS=1 UV_PYTHON_DOWNLOADS=never
mkdir -p "${DOT_SAGE}" "${MAXIMA_OBJDIR}" "${MPLCONFIGDIR}"

kernel=$(uname -s)
if [[ ${kernel} == Darwin ]]
then
  # Cocoa's fork guard otherwise aborts worker processes on GUI-initialized macOS.
  export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
else
  : "${CC:?The published development environment must set CC on Linux}"
  gcc_version=$("${CC}" -dumpversion)
  export FC="${brew_prefix}/opt/gcc/bin/gfortran-${gcc_version%%.*}"
  export PATH="${brew_prefix}/opt/binutils/bin:${PATH}"
fi

cd "${VALIDATION_ROOT}/sage-11.0.beta6"
case ${1:?Specify build or test} in
  build)
    python -I "${script_dir}/sage-validation.py" check-before-build
    feature_options=()
    for feature in bliss brial coxeter3 eclib libbraiding libhomfly mcqd meataxe rankwidth sirocco tdlib
    do
      feature_options+=("-Csetup-args=-D${feature}=enabled")
    done
    uv pip install --python "${VIRTUAL_ENV}/bin/python" --offline --no-sources --no-deps \
      --no-build-isolation --verbose -Cbuild-dir="${VALIDATION_ROOT}/meson-build" \
      -Csetup-args=-Dbuild-docs=false -Csetup-args=--wrap-mode=nofallback \
      -Ccompile-args=-j2 "${feature_options[@]}" .
    python -I "${script_dir}/sage-validation.py" check-after-build
    ;;
  test)
    python -I "${script_dir}/sage-validation.py" test
    ;;
  *)
    printf 'Unknown stage: %s\n' "$1" >&2
    exit 2
    ;;
esac
