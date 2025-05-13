#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint native_add.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'native_add'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter FFI plugin project.'
  s.description      = <<-DESC
A new Flutter FFI plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }

  # This will ensure the source files in Classes/ are included in the native
  # builds of apps using this FFI plugin. Podspec does not support relative
  # paths, so Classes contains a forwarder C file that relatively imports
  # `../src/*` so that the C sources can be shared among all target platforms.
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'
  s.script_phase = {
    :name => 'update go library',
    :script => 'touch ${BUILT_PRODUCTS_DIR}/prebuild.touch',
    :execution_position=> :before_compile,
    :input_files => ['${PODS_TARGET_SRCROOT}/../prebuild/${PLATFORM_FAMILY_NAME}/'],
    :output_files => ["${BUILT_PRODUCTS_DIR}/prebuild.touch"],
  }
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    # Flutter.framework does not contain a i386 slice.
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    # We use `-force_load` instead of `-l` since Xcode strips out unused symbols from static libraries.
    'OTHER_LDFLAGS' => "-force_load ${PODS_TARGET_SRCROOT}/../prebuild/${PLATFORM_FAMILY_NAME}/${PLATFORM_NAME}/${CURRENT_ARCH}/lib#{s.name}.a",
  }
  s.swift_version = '5.0'
end
