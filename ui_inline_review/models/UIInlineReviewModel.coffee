# imports
BaseModel = Stik.Models.BaseModel



class UIInlineReviewModel extends BaseModel

  MIN_CHARS      : 25
  REQUEST_TIMEOUT: 12000
  REQUEST_HEADER :'X-Stik-Transaction-Review'


  # properties
  idAttribute: 'id'
  urlRoot: '/api/v2/reviews/'

  defaults:
    author : null
    rating : null
    content: null
    has_syndication_permission: true

    # profile attrs
    recipient:
      username: null

    # add auto-auth data
    vch_reviewer_email : $.getUrlParameter 'vch_reviewer_email'
    network_id         : $.getUrlParameter 'network_id'
    vch_hash           : $.getUrlParameter 'hash'
    vch_reviewer_uid   : $.getUrlParameter 'tuid'
    channel            : $.getUrlParameter( 'vch_channel' ) or 'inline'


  initialize : ->
    #Create a UUID
    @uuid = guid()

    super


  shouldAllowExit: ->
    has_rating  = @validateRating()
    # define min_char length to 1
    has_review  = @validateReview( 1 )
    has_network = @get( 'author' )?.network?.id?

    # is allowed since we haven't collected any info yet
    return true if not has_rating and not has_review

    # we have collected at-least some data, do we have everything we need?
    has_rating and has_review and has_network


  validate: ->
    return "Please enter a rating before continuing." unless @validateRating()
    return "Please enter a review of #{@MIN_CHARS} or more characters before continuing." unless @validateReview()


  # Validation Methods
  validateRating: ->
    @get( 'rating' )?


  validateReview: (min_chars=@MIN_CHARS) ->
    txt = @get 'content'
    txt?.replace( /\ /g, '' ).length >= min_chars


  sync : (method, model, options) ->
    options.timeout = @REQUEST_TIMEOUT

    # Store existing beforeSend
    oldBeforeSend = options.beforeSend
    options.beforeSend = (xhr) =>
      # Set a transaction header
      xhr.setRequestHeader @REQUEST_HEADER, @uuid

      # Apply any previous before send callbacks
      oldeBeforeSend.apply( @, arguments ) if oldBeforeSend?

    super method, model, options




# exports
Stik.Models.UIInlineReviewModel = UIInlineReviewModel