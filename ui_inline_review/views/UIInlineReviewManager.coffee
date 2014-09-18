# imports
Mixins = Stik.Mixins
Views  = Stik.Views



class UIInlineReviewManager extends Views.UIInlineReviewAbstractView

  tagName  : 'article'
  className: 'reveal-modal expand card-stack ui-inline-review'

  twigOptions:
    href : '/templates/components/ui_inline_review/manager.twig'
    base : '/templates'

  initialize: (settings={}) ->
    super

    # mixin card-stack
    _.defaults @, Mixins.CardStack

    # cache subviews
    @views.review  = new Views.UIInlineReviewReview       model: @model, mediator: @mediator, id: 'write review'
    @views.verify  = new Views.UIInlineReviewVerify       model: @model, mediator: @mediator, id: 'verify review'
    @views.confirm = new Views.UIInlineReviewConfirmation model: @model, mediator: @mediator, id: 'confirm review'

    # set subview's element
    @on 'el-update', ->
      @views.review.setElement  @$ '#inlineReviewManagerReview'
      @views.verify.setElement  @$ '#inlineReviewManagerVerification'
      @views.confirm.setElement @$ '#inlineReviewManagerConfirmation'

      # init off card-stack, if we haven't already
      # card-stack init needs to happen AFTER setting subview element
      @initializeCardStack()

    # delegating hide to card-stack since that's what it does best
    @once 'show-card',   @showSubView, @
    @on   'hidden-card', @hideSubView, @

    # model listeners
    @listenTo @model, 'error', @handleErrorState, @

    # request listeners
    @listenTo @model, 'request',    => @handleWaitState true
    @listenTo @model, 'sync error', => @handleWaitState false


  fillInNotice: ($notice) ->
    $wrapper = @$ '#notices'

    # hide previous notices
    $wrapper.find( '.flash' ).slideUp( 'fast' ).delay().remove()

    # inject the notice, slide it down, wait, and then slide it up
    $wrapper.prepend $notice.hide().delay().slideDown( 'slow' ).delay( 3000 ).slideUp( 'fast' )


  remove: ->
    super

    # remove subviews
    view.remove() for action, view of @views


  findSubView: (view_id) ->
    # is the view_id already a view?
    if view_id instanceof Views.UIInlineReviewAbstractView
      view_id

    # find the view from the view_id
    else
      _.find @views, (view) -> view if view.el.id is view_id


  showSubView: (view_id) ->
    subview = @findSubView view_id

    # broadcast to subview it is being shown
    subview.trigger 'show'

    # log event
    @mediator.trigger 'logger', "view-#{subview.id}"

    # switch to subview using card-stack
    @switchToCard subview.el.id

    @


  hideSubView: (view_id) ->
    # find the subview to hide
    subview = @findSubView view_id
    subview.trigger 'hide'


  showReview: ->
    @showSubView @views.review


  showVerify: ->
    @showSubView @views.verify


  showConfirm: ->
    @showSubView @views.confirm


  ### Event Handlers ###
  handleErrorState: ->
    # build notice
    $notice = @flash type:'error', text:'Unfortunately there was an error.'

    # display notice
    @fillInNotice $notice


  handleWaitState: (in_progress) =>
    # build notice
    $notice = @flash type:'info', text:'This seems to be taking a while. Sit tight.'

    # queue the "please wait" notice
    if in_progress
      request_timeout = @model.REQUEST_TIMEOUT / 1.5
      @timeout = setTimeout (=> @fillInNotice $notice), request_timeout

    # dequeue the "please wait" notice
    else
      clearTimeout( @timeout ) if @timeout?



# exports
Stik.Views.UIInlineReviewManager = UIInlineReviewManager