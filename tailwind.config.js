/** @type {import('tailwindcss').Config} */
const tailwindColors = require("tailwindcss/colors");

module.exports = {
  content: ["./src/**/*.{html,js,gleam}"],
  darkMode: "class",
  theme: {
    extend: {
      colors: {
        ...tailwindColors,
        gray: tailwindColors.neutral,
      },
      typography: {
        DEFAULT: {
          css: {
            maxWidth: "100ch",
          },
        },
      },
    },
  },
  plugins: [require("@tailwindcss/typography"), require("tailwindcss-animate")],
};
