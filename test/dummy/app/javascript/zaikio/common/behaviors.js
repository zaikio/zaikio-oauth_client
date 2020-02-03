import { delegate } from '@rails/ujs';

// Navigation menu
delegate(document, '*[data-behavior=open_navigation_menu]', 'click', event => {
  document.querySelector('#navigation').classList.add('is-visible')
});

delegate(document, '*[data-behavior=close_navigation_menu]', 'click', event => {
  document.querySelector('#navigation').classList.remove('is-visible')
});

delegate(document, '#navigation', 'click', event => {
  if (!event.target.closest('.navigation__menu') && !event.target.closest('.navigation__dashboard')) {
    document.querySelector('#navigation').classList.remove('is-visible');
  }
});


// Classic menu
delegate(document, '*[data-behavior=open_menu]', 'click', event => {
  event.target.nextElementSibling.classList.add('is-visible');
});

delegate(document, 'body', 'click', event => {
  if (!event.target.closest('.menu')) {
    document.querySelector('.menu__list').classList.remove('is-visible');
  }
});
