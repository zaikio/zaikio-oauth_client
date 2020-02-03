import axios from 'axios';

axios.interceptors.request.use(config => {
  config.headers['X-CSRF-TOKEN'] = document.querySelector(
    'meta[name=csrf-token]'
  ).content;
  return config;
});

export { axios };
