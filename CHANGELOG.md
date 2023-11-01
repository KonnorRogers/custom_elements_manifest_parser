## Unreleased

## [0.2.9] - 11/01/2023

- Fixed a bug where `parent_module` was not serializing `exports` or `children`

## [0.2.3] - 10/08/2023

- Fixed a bug where `ClassLikeStruct` was not getting properly serialized.
- Fixed a bug with `static` types on members.
- Fixed a bug with inconsistent naming of `inheritedFrom` on data_types.

## [0.2.2] - 10/08/2023

- Fixed a bug where `ClassDeclaration` wasn't properly serializing it's data types.

## [0.2.1] - 10/07/2023

- Added a `Parser#find_all_tag_names` method to the parser that returns a Hash keyed off the tag name.

## [0.2.0] - 10/07/2023

- Added a `Parser#find_by_tag_names(['tag-name'])` method to the parser that returns a Hash keyed off the tag name.
- Removed `tag_names` as a parameters for `Parser#find_custom_elements`

## [0.1.0] - 2023-10-03

- Initial release
