# imports
AbstractView = Stik.Views.UIInlineReviewAbstractView



class UIInlineReviewConfirmation extends AbstractView

  twigOptions:
    href: '/templates/components/ui_inline_review/_confirmation.twig'
    base : '/templates'

  events:
    'click a' : 'handleRecommendClick'


  initialize: ->
    super


  ### Event Handlers ###
  handleRecommendClick: (evt) ->
    # allow hyperlink to determine route

    # log event
    would_refer = $( evt.currentTarget ).data 'would-refer'
    @mediator.trigger 'logger', 'click-would refer', would_refer



# exports
Stik.Views.UIInlineReviewConfirmation = UIInlineReviewConfirmation