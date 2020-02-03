import hljs from 'highlightjs'

document.addEventListener('turbolinks:load', function () {
  document.querySelectorAll('pre code').forEach((block) => {
    hljs.highlightBlock(block);
  });
});