#
# candlefinance_send+autolinking.rb
# Mon Sep 02 2024
# This file was generated by nitrogen. DO NOT MODIFY THIS FILE.
# https://github.com/mrousavy/nitro
# Copyright © 2024 Marc Rousavy @ Margelo
#

# This is a Ruby script that adds all files generated by Nitrogen
# to the given podspec.
#
# To use it, add this to your .podspec:
# ```ruby
# Pod::Spec.new do |spec|
#   # ...
#
#   # Add all files generated by Nitrogen
#   load 'nitrogen/generated/ios/candlefinance_send+autolinking.rb'
#   add_nitrogen_files(spec)
# end
# ```

def add_nitrogen_files(spec)
  Pod::UI.puts "[NitroModules] Adding candlefinance_send specs..."

  spec.dependency "NitroModules"

  current_source_files = spec.attributes_hash['source_files'] || []
  spec.source_files = current_source_files + [
    # Generated cross-platform specs
    "nitrogen/generated/shared/**/*.{h,hpp,c,cpp,swift}",
    # Generated bridges for the cross-platform specs
    "nitrogen/generated/ios/**/*.{h,hpp,c,cpp,swift}",
  ]

  current_public_header_files = spec.attributes_hash['public_header_files'] || []
  spec.public_header_files = current_public_header_files + [
    # Generated specs
    "nitrogen/generated/shared/**/*.{h,hpp}",
    # Swift to C++ bridging helpers
    "nitrogen/generated/ios/candlefinance_send-Swift-Cxx-Bridge.hpp"
  ]

  current_private_header_files = spec.attributes_hash['private_header_files'] || []
  spec.private_header_files = current_private_header_files + [
    # iOS specific specs
    "nitrogen/generated/ios/c++/**/*.{h,hpp}",
  ]

  current_pod_target_xcconfig = spec.attributes_hash['pod_target_xcconfig'] || {}
  spec.pod_target_xcconfig = current_pod_target_xcconfig.merge({
    # Use C++ 20
    "CLANG_CXX_LANGUAGE_STANDARD" => "c++20",
    # Enables C++ <-> Swift interop (by default it's only C)
    "SWIFT_OBJC_INTEROP_MODE" => "objcxx",
  })
end
