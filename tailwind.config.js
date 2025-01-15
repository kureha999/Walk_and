module.exports = {
  content: [
    './app/views/**/*.html.erb',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js'
  ],
  theme: {
    extend: {
      fontFamily: {
        'kosugi': ['"Kosugi Maru"', 'sans-serif'],
        'dancing-script': ['"Dancing Script"', 'cursive'],
        'edu-au': ['"Edu AU VIC WA NT Pre"', 'sans-serif'],
      },
      colors: {
        'logo-brown': '#c19a88',
        'background-blue': '#b1cdbb',
        'text-cream': '#e4ddd5',
        'footer-color': '#7e928d',
      },
    },
  },
  plugins: [],
};