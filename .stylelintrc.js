/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

module.exports = {
  root: true,
  extends: ['stylelint-config-standard'],
  plugins: ['stylelint-order', 'stylelint-scss'],
  rules: {
    'at-rule-no-unknown': [
      true,
      {
        ignoreAtRules: ['define-mixin', 'mixin', 'include', 'extend', 'each', 'for', 'function', 'return', 'if', 'else'],
      },
    ],
    // Using quotes
    'font-family-name-quotes': null, // 修改：禁用
    'function-url-quotes': 'always',
    'selector-attribute-quotes': 'always',
    'string-quotes': 'single',
    // Disallow vendor prefixes
    'at-rule-no-vendor-prefix': null, // 修改：禁用
    'media-feature-name-no-vendor-prefix': true,
    'property-no-vendor-prefix': null, // 修改：禁用
    'selector-no-vendor-prefix': true,
    'value-no-vendor-prefix': true,
    // Specificity
    'max-nesting-depth': 4,
    'selector-max-specificity': null, // 修改：禁用
    // Miscellanea
    'color-named': null,
    'color-no-hex': null,
    'declaration-no-important': null, // 修改：禁用
    'declaration-property-unit-whitelist': null, // 修改：禁用(已废弃)
    'declaration-property-unit-allowed-list': null, // 新规则名
    'number-leading-zero': 'never',
    'order/properties-alphabetical-order': null, // 修改：禁用
    'selector-max-type': null, // 修改：禁用

    'selector-type-no-unknown': [
      true,
      {
        ignore: ['custom-elements'],
      },
    ],
    // Notation
    'font-weight-notation': null, // 修改：禁用
    // URLs
    'function-url-no-scheme-relative': true,
    // Max line length
    'max-line-length': null, // 修改：禁用
    // Fix
    indentation: null, // 修改：禁用
    'declaration-colon-newline-after': null,
    'value-list-comma-newline-after': null,
    'no-descending-specificity': null,
    'selector-list-comma-newline-after': null,
    // 新增：禁用空行相关规则
    'rule-empty-line-before': null,
    'at-rule-empty-line-before': null,
    'declaration-empty-line-before': null,
    'block-closing-brace-empty-line-before': null,
    'max-empty-lines': null,
    'selector-combinator-space-after': null,
    'selector-combinator-space-before': null,
    'no-empty-source': null,
    'font-family-no-missing-generic-family-keyword': null,
    'function-calc-no-unspaced-operator': null,
  }
}