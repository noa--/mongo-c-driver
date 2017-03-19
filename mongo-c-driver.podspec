upstream_version = "1.6.1"
cocoapods_prerelease = "rc1"

if cocoapods_prerelease
  pod_version = "#{upstream_version}-cocoapods-#{cocoapods_prerelease}"
  source = { :git => "https://github.com/paulmelnikow/mongo-c-driver.git", :tag => pod_version }
else
  pod_version = upstream_version
  source = { :git => "https://github.com/mongodb/mongo-c-driver.git", :tag => upstream_version }
end

Pod::Spec.new do |s|
  s.name                 = "mongo-c-driver"
  s.version              = pod_version
  s.summary              = "A high-performance MongoDB driver for C"
  s.description          = <<-DESC
                           mongo-c-driver is a client library written in C for MongoDB
                           DESC
  s.homepage             = "https://github.com/mongodb/mongo-c-driver"
  s.license              = { :type => "Apache License, Version 2.0", :file => "COPYING" }
  s.author               = "MongoDB"
  s.documentation_url    = "http://mongoc.org/libmongoc/#{upstream_version}/index.html"
  s.social_media_url     = "http://twitter.com/mongodb"
  s.source               = source
  s.source               = { :git => "https://github.com/mongodb/mongo-c-driver.git", :tag => "#{s.version}" }
  s.prepare_command      = <<-PREPARE

  sed -i '' 's/<mongoc-config.h>/"mongoc-config.h"/' src/mongoc/mongoc-socket.h

  cat > libmongoc.modulemap <<MODULEMAP
  framework module mongoc {
    umbrella header "mongoc/mongoc.h"

    exclude header "mongoc/mongoc-crypto-cng.h"
    exclude header "mongoc/mongoc-stream-tls-libressl.h"
    exclude header "mongoc/mongoc-stream-tls-openssl.h"
    exclude header "mongoc/mongoc-stream-tls-secure-channel.h"
    exclude header "mongoc/mongoc-stream-tls-secure-transport.h"
    exclude header "mongoc/utlist.h"

    export *
    module * { export * }
  }
  MODULEMAP

  ./autogen.sh && ./configure --with-libbson=no --enable-ssl=darwin --enable-sasl=no

  PREPARE
  s.source_files         = "src/mongoc/*.{c,h}"
  s.header_mappings_dir  = "src"
  s.private_header_files = "src/mongoc/*-private.h"
  s.module_name          = "mongoc"
  s.module_map           = "libmongoc.modulemap"
  s.preserve_paths       = "src/mongoc/*.{def,defs}", "src/libmongoc.modulemap"
  s.compiler_flags       = "-DMONGOC_COMPILATION"
  s.frameworks           = "Security"
  s.requires_arc         = false

  # Because mongo sources #include <bson.h>
  s.pod_target_xcconfig  = { "HEADER_SEARCH_PATHS" => "$(PODS_ROOT)/libbson/src/bson" }

  # Because mongo public headers #include <bson.h>
  s.user_target_xcconfig = { "HEADER_SEARCH_PATHS" => "$(PODS_ROOT)/libbson/src/bson" }

  s.dependency             "libbson", ">= #{s.version}", "< 2.0"

  s.osx.deployment_target = "10.7"

  # Darwin SSL doesn't work on iOS.
  # s.ios.deployment_target = "10.0"
end
