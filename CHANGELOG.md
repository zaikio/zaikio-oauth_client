# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## 0.7.1 - 2021-03-17

* Fix incorrect const_defined? behaviour when initializing without zaikio-hub-models gem

## 0.7.0

* Don't set `cookies.encrypted[:origin]` when passing `?origin` to `new_session_path`
* `show_signup`, `force_login` and `state` params are now passed through `new_session_path`.

## 0.6.1

* Fixed token lookup by searching through requested scopes not through granted scopes. You need to run `$ rails zaikio_oauth_client:install:migrations` to apply latest migrations.

## 0.6.0

* Improved index to improve access token lookup, run `$ rails zaikio_oauth_client:install:migrations` to apply

## 0.5.1

* Fixed Namespace for Models gem

## 0.5.0

* **BREAKING** Renames `Zaikio::Directory` to `Zaikio::Hub`

## 0.4.4 - 2021-01-19

* Fix another compatibility issue with Ruby 3.0

## 0.4.3 - 2021-01-15

* Automatically publish to RubyGems

## 0.4.2 - 2021-01-11

* Fix compatibility issues with Ruby 3.0
