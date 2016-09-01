#= require jquery
#= require jquery_ujs
#= require turbolinks
#= require underscore
#= require gmaps/google
#= require_tree .

class RichMarkerBuilder extends Gmaps.Google.Builders.Marker
  create_marker: ->
    options = _.extend @marker_options(), @rich_marker_options()
    @serviceObject = new RichMarker options

  rich_marker_options: ->
    marker = document.createElement("div")
    marker.setAttribute 'class', 'marker_container'
    marker.innerHTML = @args.marker
    { content: marker }

class InfoBoxBuilder extends Gmaps.Google.Builders.Marker
  create_infowindow: ->
    return null unless _.isString @args.infowindow

    @lol = console.log(@args)
    boxText = document.createElement("div")
    boxText.setAttribute('class', 'marker_container')
    boxText.innerHTML = @args.infowindow

    @infowindow = new InfoBox(@infobox(boxText))

  infobox: (boxText) ->
    content: boxText
    pixelOffset: new google.maps.Size(-140, 0)
    boxStyle:
      width: "280px"

@buildMap = (markers) ->
  handler = Gmaps.build 'Google', { builders: { Marker: InfoBoxBuilder} }

  handler.buildMap { provider: {}, internal: {id: 'map'} }, ->
    console.log(markers)
    Gmaps.store.markers = markers.map((m) ->
      marker = handler.addMarker(m)
      marker.serviceObject.set 'id', m.id
      marker
    )
    console.log(markers)
    handler.bounds.extendWith(Gmaps.store.markers)
    handler.fitMapToBounds()

