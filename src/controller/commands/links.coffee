trim = (str) ->
  str = str.replace /^\s+/g, ''
  str.replace /\s+$/g, ''

getVideo = (link) ->
  $(link).attr('data-modal-iframe')

getLectureItem = (lectureItemResources, type) ->
  $(lectureItemResources).find("a[title='#{type}']").attr('href')

getLectures = (section) ->
  $(section).next().find('li').map(->
    link = $(this).find('.lecture-link')
    lectureItemResources = $(this).find('.course-lecture-item-resource')
    {
      title: trim($(link).text())
      video: getVideo(link)
      slides: getLectureItem(lectureItemResources, "Slides")
      txtSubtitles: getLectureItem(lectureItemResources, "Subtitles (text)")
      srtSubtitles: getLectureItem(lectureItemResources, "Subtitles (srt)")
    }
  ).get()


getSections = () ->
  $('.course-item-list-header').map(->
    title: trim($(this).find('h3').text()), lectures: getLectures(this)
  ).get()

getCourse = () ->
  name = $('.course-topbanner-name').text()
  course: trim(name), sections: getSections()

chrome.extension.onRequest.addListener (request, sender, sendResponse) ->
  sendResponse(getCourse())
