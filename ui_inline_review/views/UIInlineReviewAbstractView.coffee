# imports
Events   = Backbone.Events
BaseView = Stik.Views.BaseView



class UIInlineReviewAbstractView extends BaseView

  initialize: (settings={}) ->
    super

    # cache mediator
    @mediator = settings.mediator ? _.extend {}, Events

    # cache flash message template
    @flash_template = twigAsync
      async: false
      href : '/templates/components/_flash.twig'
      isPromiseAlwaysReturned: false

    # event listeners
    @on 'show', @show, @
    @on 'hide', @hide, @

    # model listeners
    @listenTo @model, 'request',    @handleStateRequest,  @
    @listenTo @model, 'sync error', @handleStateComplete, @


  show: ->
    # not calling super since card-stack will take care of show
    # we just want another method for subviews to hook into
    @render()


  hide: ->
    # not calling super since card-stack will take care of hide
    # we just want another method for subviews to hook into


  flash: (notice_json={}) ->
    # create html from template
    $ @flash_template.render( notice:notice_json )


  ### FillIn Methods ###
  fillInProgressState: (in_progress) ->
    # fill-in elements that need to react to in_progress state


  ### Event Handlers ###
  handleStateRequest: (model, xhr, options) ->
    # do not proceed if request_silent exists
    return false if options.request_silent is true

    # disable events
    @undelegateEvents()

    # disable submit button and show in-progress inidicator
    @fillInProgressState true


  handleStateComplete: (model, xhr, options) ->
    # do not proceed if request_silent exists
    return false if options.request_silent is true

    # enable events
    @delegateEvents()

    # enable submit button and hide in-progress inidicator
    @fillInProgressState false



# exports
Stik.Views.UIInlineReviewAbstractView = UIInlineReviewAbstractView