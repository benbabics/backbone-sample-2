# imports
AbstractView = Stik.Views.UIInlineReviewAbstractView



class UIInlineReviewVerify extends AbstractView

  events:
    'click .login'           : 'handleVerifyNetwork'
    'click .continue'        : 'handleVerifyNetwork'
    'click .explanation a'   : 'handleDisplayExplanation'
    'click .privacy-control' : 'handlePrivacyChange'


  initialize: ->
    super

    # model listeners
    @listenTo @model, 'change:has_syndication_permission', @fillInPrivacyCheckbox, @


  show: ->
    super

    # cache elements
    @$checkbox = @$ '.privacy-option'

    # initially fill-in the privacy checkbox
    @fillInPrivacyCheckbox()


  ### Fill-in Handlers ###
  fillInPrivacyCheckbox: ->
    has_permission = @model.get 'has_syndication_permission'
    @$checkbox.toggleClass 'checked', has_permission


  fillInProgressState: (in_progress) ->
    # display loader
    @$( '.ui-verification' ).toggleClass 'ui-loading', in_progress


  fillInExplanation: (shoud_slide_down) ->
    # toggle explanation paragraph
    @$( '.explanation p' ).stop().slideToggle()


  ### Event Handlers ###
  handlePrivacyChange: (evt) ->
    has_permission = @model.get 'has_syndication_permission'

    # update the has_syndication_permission attr
    attrs = has_syndication_permission: not has_permission

    # do not update permission if clicking the hyperlink
    if $( evt.target ).is ':not(a)'

      # save updated attrs, but silence the request
      @model.save attrs, { wait: true, request_silent: true }


  handleVerifyNetwork: (evt) ->
    evt.preventDefault()

    # broadcast view has had a network signup attempt
    @mediator.trigger 'verify-save', @model.attributes

    # log event
    verify_label = $( evt.currentTarget ).data 'verify-label'
    @mediator.trigger 'logger', 'click-verify review', verify_label


  handleDisplayExplanation: (evt) ->
    evt.preventDefault()

    # display explanation
    @fillInExplanation true

    # log event
    @mediator.trigger 'logger', 'click-verification explanation'



# exports
Stik.Views.UIInlineReviewVerify = UIInlineReviewVerify