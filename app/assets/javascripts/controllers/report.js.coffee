#
#
class Controller.Report extends Controller.Base

	# Interpolation step size
	#
	@INTERPOLATE_DT: 1

	# Creates a new instance of Main
	#
	# @param container [String, Object] A string with an id or a DOM node to serve as a container for the view
	# @param view [View.Report] the view for this controller
	#
	constructor: ( cell_id, @container = "#paper", view ) ->
	
		super view ? new View.Report( @container )
		
		@_currentIteration = 0
		@_datasets = {}
		@_xValues = []
		@_createChildren()
		@_createBindings()
		@load( cell_id )
		
	
	# Prepends the CSS styles in the SVG
	#
	prependStyles: () ->
		# Get the right CSS file
		for sheet in document.styleSheets
			if /svg/.test(sheet.href)
				stylesheet = sheet
				break

		rules = []
		# Get all the rules in said CSS file		
		for rule in stylesheet.cssRules
			rules.push rule.cssText

		rules = rules.reduce (x, y) -> x + " " + y
		$('#paper').find('svg').prepend("<defs><style type='text/css'><![CDATA[#{rules}]]></style></defs>")
		$('.graph-report').find('svg').prepend("<defs><style type='text/css'><![CDATA[#{rules}]]></style></defs>")
		$('#paper').find('svg').attr("xmlns:xlink", "http://www.w3.org/1999/xlink")
		
	# Creates children
	#
	_createChildren: () ->
		@addChild 'cell', new Controller.Cell( @view.paper, @view, undefined, off )
		@addChild 'graphs', new Controller.Graphs( @view.paper )
		@addChild 'settings', new Controller.Settings()
		
		@view.add @controller('cell').view
		@view.add @controller('graphs').view
		
	#
	#
	_createBindings: () ->
		#@view.bindActionButtonClick( () => @onAction( arguments... ) ) 
		
	# Sets the progress bar
	#
	# @param value [Integer] the current value
	#
	_setProgressBar: ( value ) =>
		@view.setProgressBar value / @_iterations + 1 / @_iterations * @_currentIteration
		return this

	# Loads a new cell into the report view
	#
	# @param cell_id [Integer] the cell to load
	# @param callback [Function] the callback function
	# @return [jQuery.Promise] the promise
	#
	load: ( cell_id, callback ) ->
		@view.draw()
		
		promise = @controller('cell').load cell_id, callback
		promise.done( () => 
			@solveTheSystem()
		)
			
		return promise
		
	# Serializes a paper
	#
	# @return [String] the serialized paper in XML
	#
	serializePaper: () ->
		cell_svg = new XMLSerializer().serializeToString @view.paper.canvas
		$( '#report_cell_svg' ).attr( "value", cell_svg )

		graphs_svg = {}
		$( '.graph-report').each( () ->
			graph_id = ( $( this ).attr('id') ).replace /graph-/, ""
			graph_svg = new XMLSerializer().serializeToString $( this ).find('svg')[0]
			graphs_svg[graph_id] = graph_svg
			console.log graph_svg
		)	
		
		$( '#report_graph_data' ).attr( "value", JSON.stringify( graphs_svg ) )
		
		return cell_svg
		
	# Serializes the graph datasets
	#
	# @return [JSON] the serialized datasets
	#
	serializeDatasets: () ->
		serializedDatasets = JSON.stringify( @_datasets )
		serializedX = JSON.stringify( @_xValues )
		$( '#report_datasets' ).attr( "value", serializedDatasets )
		$( '#report_xValues' ).attr( "value", serializedX )

		return serializedDatasets

	# Concatinates the graph datasets
	#
	# @return [Object] the concatinated datasets
	#
	_concatDatasets: (datasets) ->
		for key, dataset of datasets
			if key not of @_datasets
				@_datasets[key] = { yValues: [] }
			@_datasets[key].yValues.push dataset.yValues...
		
		@_xValues.push datasets[key].xValues...

	# Solve the system
	#
	# @return [Tuple<CancelToken, jQuery.Promise>] a token and the promise
	#
	solveTheSystem: () ->
		
		@_iterations = @controller('settings').options.simulate.iterations
		@_currentIteration = 0

		iterationDone = ( results, from, to ) =>
			@controller( 'graphs' ).show( results.datasets, @_currentIteration > 0, 'key' )
			@_concatDatasets results.datasets

			@_currentIteration++
			@_setProgressBar 0

		@view.showProgressBar()
		settings = @controller('settings').options
		override = { dt: Report.INTERPOLATE_DT, interpolate: on }
		[ token, promise ] = @controller('cell').startSimulation( settings.simulate, iterationDone, _( override ).defaults (settings.ode) )
		promise.done( () => 
			$('#create-pdf').removeProp 'disabled'
			$('#create-csv').removeProp 'disabled'
			@view.hideProgressBar()
			@prependStyles()
			@serializePaper()
			@serializeDatasets()
		)
		promise.progress @_setProgressBar
		
	# Runs on an action (click)
	#
	# @param event [jQuery.Event] the event
	#
	onAction: ( event ) =>
		
		target = $( event.currentTarget )
		action = target.data( 'action' )
		action = action.charAt(0).toUpperCase() + action.slice(1)
		
		@[ 'on' + action ]?( target, enable, success, error )
		
	