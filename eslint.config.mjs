import js from "@eslint/js";
import globals from "globals";

export default [
  {
    ignores: [
      "node_modules/**",
      "vendor/**",
      "tmp/**",
      "public/assets/**",
      "app/assets/builds/**"
    ]
  },
  {
    ...js.configs.recommended,

    languageOptions: {
      ecmaVersion: "latest",
      sourceType: "module",
      globals: {
        ...globals.browser,
        ...globals.node
      }
    },

    linterOptions: {
      noInlineConfig: true
    }
  }
];