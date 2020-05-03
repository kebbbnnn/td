#!/bin/sh

while test $# -gt 0; do
    case "$1" in
        --platform)
                    shift
                    arg_platforms=("$@")
                    shift
                    ;;
        *)
                    break;
                    ;;
    esac
done  

echo "platform selected : ${arg_platforms[@]}";

valid_platforms=("macOS iOS watchOS tvOS")

declare -a platforms=()

for i in ${valid_platforms[@]}; do
    for j in ${arg_platforms[@]}; do
        if [ "$i" == "$j" ]; then
            platforms+=($j)
        fi
    done
done

if (( ${#platforms[@]} )); then
    git clone https://github.com/pybee/Python-Apple-support
    cd Python-Apple-support
    git checkout 60b990128d5f1f04c336ff66594574515ab56604
    cd ..

    for platform in $platforms;
    do
        echo $platform
        cd Python-Apple-support
        #NB: -j will fail
        make OpenSSL-$platform
        cd ..
        rm -rf third_party/openssl/$platform
        mkdir -p third_party/openssl/$platform/lib
        cp ./Python-Apple-support/build/$platform/libcrypto.a third_party/openssl/$platform/lib/
        cp ./Python-Apple-support/build/$platform/libssl.a third_party/openssl/$platform/lib/
        cp -r ./Python-Apple-support/build/$platform/Support/OpenSSL/Headers/ third_party/openssl/$platform/include
    done
else
    echo ERROR: Platforms: \(${arg_platforms[@]}\) are invalid. 1>&2
    exit 1 # terminate and indicate error
fi