class Model.Metabolism extends Model.Module

	# Constructor for Metabolism
	#
	# @param params [Object] parameters for this module
	# @param substrate [String] the substrate to be converted
	# @param product [String] the product after conversion
	# @param start [Integer] the initial value of metabolism, defaults to 0
	# @param name [String] the name of the metabolism, defaults to "enzym"
	# @option k [Integer] the subscription rate, defaults to 1
	# @option k_met [Integer] the conversion rate, defaults to 1
	# @option k_d [Integer] the conversion rate, defaults to 1
	# @option v [Integer] the speed scaler (vmax), defaults to 1
	# @option dna [String] the dna to use, defaults to "dna"
	# @option orig [String] the substrate to be converted, overrides substrate
	# @option dest [String] the product after conversion, overrides product
	# @option name [String] the name of the metabolism, overrides name
	#
	constructor: ( params = {}, start = 0, substrate = "s_int", product = "p_int", name = "enzym" ) ->
	
		# Step function for lipids
		step = ( t, substrates ) ->
			results = {}
			if ( @_test( substrates, @name, @orig ) )
				vmetabolism = @v * substrates[@name] * ( substrates[@orig] / ( substrates[@orig] + @k_met ) )

			if ( @_test( substrates, @dna ) )
				results[@name] = @k * substrates[@dna] - @k_d * ( substrates[@name] ? 0 )
				
			if ( vmetabolism? and vmetabolism > 0 )
				results[@orig] = -vmetabolism
				results[@dest] = vmetabolism
					
			return results
		
		# Default parameters set here
		defaults = { 
			k: 1
			k_met: 1 
			k_d : 1
			v: 1
			orig: substrate
			dest: product
			dna: "dna"
			name: name
		}
		
		params = _( defaults ).extend( params )
		
		starts = {};
		starts[params.name] = start
		starts[params.dest] = 0
		super params, step, starts

(exports ? this).Model.Metabolism = Model.Metabolism