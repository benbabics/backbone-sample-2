# imports
AbstractView = Stik.Views.UIInlineReviewAbstractView



class UIInlineReviewReview extends AbstractView

  events:
    'keyup textarea'             : 'handleReviewChange'
    'click .icon-star'           : 'handleRatingClick'
    'click .rating-instructions' : 'handleRatingInstructionsClick'
    'mouseenter .icon-star'      : 'handleRatingEnter'
    'mouseleave .star-container' : 'handleRatingLeave'
    'click .btn-submit'          : 'handleSubmitAction'


  initialize: ->
    super

    # model listeners
    @listenTo @model, 'change',  @handleChangedAttributes, @


  show: ->
    super

    # cache elements
    @$review = @$ 'textarea'
    @$rating = @$ '#rating-stars-container'
    @$submit = @$ '.btn-submit'
    @$text   = @$( '.rating-text' )
    @$stars  = $ @$( '.icon-star' ).get().reverse() # handle rtl css

    # initially fill in the submit button
    @fillInSubmitButtonInteraction()


  getRatingByElementIndex: ($target) ->
    # get the index of the element (starts at zero)
    rating = @$stars.index $target

    # increment by one so value is 1-5
    ++rating


  ### Fill-in Methods ###
  fillInRatingStarsText: (rating) ->
    # remove "selected" from all elements
    @$( '.icon-star, .rating-text' ).removeClass 'selected'

    # do not proceed if rating is null
    # otherwise decrement since finding the elemtn is index based
    if rating? then --rating else return false

    # add "selected" to appropriate elements
    @$stars.eq( rating ).addClass 'selected'
    @$text.eq( rating ).addClass 'selected'


  fillInTodosListItems: ->
    @$rating.parent( 'li' ).toggleClass 'complete', @model.validateRating()
    @$review.parent( 'li' ).toggleClass 'complete', @model.validateReview()


  fillInSubmitButtonInteraction: ->
    @$submit.toggleClass 'disabled', not @model.isValid()


  fillInProgressState: (in_progress) ->
    # toggle enable/disable submit button and show in-progress inidicator
    @$submit.toggleClass( 'in-progress', in_progress ).attr 'disabled', in_progress


  ### Event Handlers ###
  handleRatingClick: (evt) ->
    rating = @getRatingByElementIndex evt.currentTarget
    @model.set 'rating', rating
    @fillInRatingStarsText rating

    # log event
    @mediator.trigger 'logger', 'click-star rating', null, rating


  handleRatingInstructionsClick: ->
    rating = @$stars.length
    @model.set 'rating', rating
    @fillInRatingStarsText rating


  handleRatingEnter: (evt) ->
    if $( 'html' ).hasClass 'no-touch'
      rating = @getRatingByElementIndex evt.currentTarget
      @fillInRatingStarsText rating


  handleRatingLeave: ->
    rating = @model.get 'rating'
    @fillInRatingStarsText rating


  handleReviewChange: ->
    review_text = @$review.val()
    @model.set 'content', review_text


  handleChangedAttributes: ->
    @fillInTodosListItems()
    @fillInSubmitButtonInteraction()


  handleSubmitAction: (evt) ->
    evt.preventDefault()

    # is the model valid to save?
    if @model.isValid()
      @mediator.trigger 'review-save', @model.attributes

    # handle error message if not
    else
      alert @model.validationError

    # log event
    rev_length = @model.get( 'content' )?.length or 0
    is_valid   = if @model.isValid() then 'is valid' else 'not valid'
    @mediator.trigger 'logger', 'click-submit review', is_valid, rev_length




# exports
Stik.Views.UIInlineReviewReview = UIInlineReviewReview