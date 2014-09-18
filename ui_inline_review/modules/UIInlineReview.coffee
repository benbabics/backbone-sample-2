# imports
Events          = Backbone.Events
Helpers         = Stik.Helpers
Views           = Stik.Views
Models          = Stik.Models
Collections     = Stik.Collections
AnalyticsHelper = Stik.AnalyticsHelper



class UIInlineReview

  ANALYTICS_CATEGORY         = 'Inline Review Wizard'
  ERROR_WITHOUT_MODEL        = 'The module UIInlineReview requires a reference to the "profileModel" for instantiation.'
  WARNING_WITHOUT_COLLECTION = 'The module UIInlineReview supports a to a "reviewsCollection" to "add" review models to.'
  TEXT_SHOULD_ALLOW_EXIT     = "You haven't finished your review yet. Do you want to leave without finishing?"


  constructor: (settings={}) ->

    # mixin events
    _.extend @, Events

    # create mediator
    @mediator = _.extend {}, Events

    # analytics helper
    @analytics = AnalyticsHelper

    # set the category for analytics
    @analytics.setCategory ANALYTICS_CATEGORY

    # This module requires a reference to the profileModel
    if not settings.profileModel?
      return console?.error ERROR_WITHOUT_MODEL

    # This module supports a reference to a reviews collection to add to
    if not settings.reviewsCollection?
      console?.warn WARNING_WITHOUT_COLLECTION

    # cache instance
    @reviewManager = null

    # cache model references
    @reviewModel       = null
    @userSessionModel  = Stik.models.user
    @profileModel      = settings.profileModel
    @reviewsCollection = settings.reviewsCollection or new Collections.BaseCollection()

    # setup listeners
    @on 'add',              @handleAddingModule,            @
    @on 'remove',           @handleRemovingModule,          @
    @on 'delegate-on-exit', @handleShouldAllowExitDelegate, @

    # mediator listeners
    @mediator.on 'review-save', @handleReviewSave,     @
    @mediator.on 'verify-save', @handleVerifySave,     @
    @mediator.on 'logger',      @handleAnalyticsEvent, @

    # catch window beforeunload event and confirm exiting review
    $( window ).bind 'beforeunload', @handleShouldAllowWindowUnload


  ### reviewManager View Methods ###
  createReviewManager: ->
    # remove view if it already exists
    @destroyReviewManager()

    # create reviewModel
    @reviewModel = new Models.UIInlineReviewModel
      recipient:
        username: @profileModel.get 'username'

    # create reviewManager view
    @reviewManager = new Views.UIInlineReviewManager
      mediator: @mediator
      model   : @reviewModel

    # Add ProfileModel to Twig global context
    Twig.addToGlobalContext
      inlineReviewProfile: @profileModel.attributes
      isLoggedIn         : @userSessionModel.isLoggedIn()

    # broadcast to other clients the state of the module
    @trigger 'create', @reviewManager.render().$el


  destroyReviewManager: ->
    # do not proceed if the reviewManager doesn't exist
    return unless @reviewManager?

    # broadcast to other clients the state of the module
    @trigger 'destroy', @reviewManager.$el

    # remove the view
    @reviewManager.remove()
    @reviewManager = null


  updateReviewModelWithUserDetails: ->
    session = @userSessionModel.attributes
    network = session.fb or session.IN

    # construct author data for the reviewModel
    @reviewModel.set 'author', {
      network    : { id: network.int_network_id },
      network_uid: network.vch_userid
    }


  ### Analytics ###
  handleAnalyticsEvent: (action, label, value) ->
    # track universal category event data
    @analytics.trackUniversalCategoryEvent action, label, value

    # kissmetrics vars
    action   = "#{action}".replace /\ /g, ''
    label    = "#{label}".replace /\ /g, ''
    category = "#{ANALYTICS_CATEGORY}".replace /\ /g, ''

    # track kissmetrics event
    @analytics.trackKmEvent "#{category} #{action} #{label}"


  ### Event Handlers ###
  handleAddingModule: ->
    @createReviewManager()


  handleRemovingModule: ->
    @destroyReviewManager()


  handleShouldAllowExitDelegate: (delegate) ->
    message  = TEXT_SHOULD_ALLOW_EXIT
    can_exit = @reviewModel.shouldAllowExit()

    # invoke delegate without a prompt
    if can_exit then return delegate()

    # display prompt and invoke delegate, if accepted
    if confirm( message ) then delegate()


  handleShouldAllowWindowUnload: =>
    message  = TEXT_SHOULD_ALLOW_EXIT
    can_exit = @reviewModel.shouldAllowExit()

    # display prompt since we shouldn't exit
    return message unless can_exit


  handleReviewSave: (attrs) ->
    # if our user is already logged-in then we need
    # to merge specific userSessionModel attrs before we save
    if @userSessionModel.isLoggedIn()
      @updateReviewModelWithUserDetails()

    # save the reviewModel
    @reviewModel.save().done =>
      @reviewManager.showVerify()

      # log event
      is_logged_in = if @userSessionModel.isLoggedIn() then 'yes' else 'no'
      @mediator.trigger 'logger', 'onsubmitreview-is logged in', is_logged_in


  handleVerifySave: (attrs) ->
    saveReview = =>
      @reviewModel.save().done =>           # save the updated review model
        @reviewManager.showConfirm()        # show the confirmation
        @reviewsCollection.add @reviewModel # add reviewModel to the reviewsCollection

        # log event
        has_permission = if attrs.has_syndication_permission then 'yes' else 'no'
        @mediator.trigger 'logger', 'onverifyreview-has syndication permission', has_permission

    # is our user is already logged-in?
    if @userSessionModel.isLoggedIn()
      saveReview()

    else
      # when the userSessionModel has changed
      # merge specific userSessionModel attrs before we save
      @userSessionModel.once 'change:int_people_id', =>
        @updateReviewModelWithUserDetails()
        saveReview()



# exports
Stik.Modules ?= {}
Stik.Modules.UIInlineReview = UIInlineReview