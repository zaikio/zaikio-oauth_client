addEventListener("direct-upload:initialize", event => {
  const { target, detail } = event
  const { id, file } = detail
  target.insertAdjacentHTML("beforebegin", `
    <div id="file-field-progress-${id}" class="file-field__progress" style="width: 0%"></div>
  `)
})

addEventListener("direct-upload:progress", event => {
  const { id, progress } = event.detail
  const progressElement = document.getElementById(`file-field-progress-${id}`)
  progressElement.style.width = `${progress}%`
})
