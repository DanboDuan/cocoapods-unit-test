# cocoapods-unit-test

A cocoapods plugin to work with Unit-Test

## Installation

Just install it

```
gem install cocoapods-unit-test
```

or use Gemfile with `bundle install`

```
source 'https://rubygems.org/'

gem 'cocoapods', '>= 1.8.4'
gem 'xcpretty','~> 0.3.0'
gem 'cocoapods-unit-test','~ 1.0'
```

## Usage

### 1. modify Podspec

- add test_spec
- add dependency XcodeCoverage

```
Pod::Spec.new do |s|
  s.name             = 'TestExample'
  ...
  
  s.subspec 'Core' do |c|
    ...
  end
  
  s.test_spec 'Tests' do |h|
    h.source_files = 'TestExample/Tests/**/*.{h,m}'
    h.dependency 'TestExample/Core'
    h.dependency 'XcodeCoverage','>= 1.3.2'
    h.frameworks = 'UIKit','Foundation'
  end
end

```

### 2. Add plugin in Podfile

- if you just test with develop pod, ignore the names parameter
- or use names if you have more than one pod to Test

```

## use names if you have more than one pod to Test
plugin 'cocoapods-unit-test',
	:names => ["TestExample"] 


target 'Example' do
  pod 'XcodeCoverage', '>= 1.3.2'
  pod 'TestExample', 
  	:path => '../',
  	:testspecs => ["Tests"]
end

```

### 3. run pod install

```
bundle exec pod install
```

### 4. Testing

- testing with cli with pod name `TestExample`
- simulator default is iPhone 8, you can change it

```
bundle exec pod test TestExample --simulator='iPhone 8'
```

- auto open result or you can check it



## Example

see []

## Contribute

if you like


