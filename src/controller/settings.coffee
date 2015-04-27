trim = (str) ->
  str = str.replace /^\s+/g, ''
  str.replace /\s+$/g, ''

class SettingsController

  tasksMap: {}
  tasks: []
  fileExtensions:
    video: '.mp4'
    slides: '.pdf'
    txtSubtitles: '.txt'
    srtSubtitles: '.srt'

  constructor: ($scope, @store, @classesService, @timeout) ->
    @incomingTasks = @store.incomingTasks()
    @scope = $scope
    $scope.filePattern = '#{course} #{sectionIndex}.#{lectureIndex} #{lecture}'
    $scope.incomings = @incomingTasks
    $scope.inclusionTypes = 
      video: true
      slides: false
      txtSubtitles: false
      srtSubtitles: false

    $scope.filename = (section, lecture, sectionIndex, lectureIndex) =>
      @filename section, lecture, sectionIndex, lectureIndex

    $scope.hasIncomingTasks = @hasIncomingTasks()
    $scope.uncompleted = () => @uncompleted()
    $scope.selectAll = () => @selected(true)
    $scope.selectNone = () => @selected(false)
    $scope.cancel = () =>
      $('#incomingModal').modal('hide')
      @clearIncoming()

    $scope.download = () =>
      $('#incomingModal').modal('hide')
      @download()

    $scope.taskIcon = (task) =>
      @taskIcon(task)

    if (@hasIncomingTasks())
      $('#incomingModal').modal()

    chrome.downloads.onChanged.addListener (downloadDelta) =>
      @downloadChange downloadDelta

  clearIncoming: ->
    @store.clearIncoming()

  download: ->
    @tasksMap = {}
    @tasks = []
    
    for section, sectionIndex in @incomingTasks.sections
      for lecture, lectureIndex in section.lectures
        if lecture.selected
          for inclusionType, isIncluded of @scope.inclusionTypes
            @tasks.push @getTask(section, lecture, sectionIndex, lectureIndex, inclusionType) if isIncluded && lecture[inclusionType]
    @clearIncoming()
    @scope.tasks = @tasks

    @prepareTasks @tasks, 0

  prepareTasks: (tasks, index) ->
    if index < tasks.length
      @prepareTask(tasks[index])
      @timeout =>
        @prepareTasks tasks, index + 1
      , 100

  prepareTask: (task) ->
    task.downloadItem = @getVideoLink(task.downloadItem) if task.type is 'video'
    task.state = 'time'
    @downloadTask task

  getTask: (section, lecture, sectionIndex, lectureIndex, type) ->
    filename: @filename(section, lecture, sectionIndex, lectureIndex, type), downloadItem: lecture[type], type: type

  filename: (section, lecture, sectionIndex, lectureIndex, type) ->
    if type is 'slides'
      extension = lecture[type].subscript(lecture[type].lastIndexOf('.'))
    name = @scope.filePattern + (extension || @fileExtensions[type] || '')
    name.interpolate
      course: @scope.incomings.course,
      section: section.title,
      lecture: lecture.title,
      sectionIndex: sectionIndex,
      lectureIndex: lectureIndex,
      sectionNumber: sectionIndex + 1,
      lectureNumber: lectureIndex + 1

  selected: (value) ->
    for section in @incomingTasks.sections
      for lecture in section.lectures
        lecture.selected = value

  hasIncomingTasks: ->
    @incomingTasks?.sections?.length > 0

  uncompleted: ->
    count = 0
    @tasks?.map (task) ->
      count++ if task?.state != 'ok'
    count

  taskIcon: (task) ->
    return 'icon-refresh' if !task.state
    "icon-#{task.state}"

  getVideoLink: (link) ->
    result = ''
    $.ajax
      url: link,
      success: (data) =>
        match = data.match /.*?(<source.*?>).*/g
        result = trim(match[0]).replace(/^.*?src=./, '').replace(/\".*$/, '')
      ,
      async: false
    result

  downloadTask: (task) ->
    name = task.filename
    if @scope.subdirectory && @scope.subdirectory.length
      name = @scope.subdirectory + "/" + name.clear()
    else
      name = name.clear()

    params = {url: task.downloadItem, filename: name}
    console.log params
    chrome.downloads.download params, (id) =>
      @tasksMap[id] = task

  downloadChange: (downloadDelta) ->
    @timeout =>
      task = @tasksMap[downloadDelta.id]
      task.state = 'circle-arrow-down'
      if downloadDelta.state?.current == 'complete'
        task.state = 'ok'

String::interpolate = (values) ->
  @replace /#{(\w*)}/g, (ph, key) ->
    values[key]

String::clear = () ->
  str = @replace(/.\[.*?\]/g, '')
  str.replace(/[\:\/\\,\?"]+/g, '')

SettingsController.$inject = ['$scope', 'store', 'classesService', '$timeout']