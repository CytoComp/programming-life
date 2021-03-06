require 'test_helper'
require 'selenium-webdriver'



class MainViewTest < ActionDispatch::IntegrationTest

	setup do
		@driver = Selenium::WebDriver.for :firefox
		@wait = Selenium::WebDriver::Wait.new :timeout => 10

		# navigate to the main view
		@driver.navigate.to "http://life.jstfy.com"
	end

	teardown do
		@driver.quit
	end

	#Mouseover event on class module-hitbox
	#Check if popover showed up on mouseover
	test "module mouseover" do
		el = @wait.until { @driver.find_element(:class, "cellgrowth-hitbox") }
		displayed = false
		if @wait.until { el.displayed? }
			@driver.mouse.move_to(el)
			pop = @wait.until { @driver.find_element(:class, "cellgrowth-box") }
			displayed = @wait.until { pop.displayed? }
		end
		assert displayed
	end
	
=begin
	#Click on module
	#Check if edit popover showed up
	test "open edit popover" do
		el = @wait.until { @driver.find_element(:class, "module-hitbox") }
		displayed = false
		if @wait.until { el.displayed? }
			el.click
			pop = @wait.until { @driver.find_element(:class, "selected") }
			displayed = @wait.until { pop.displayed? }
		end
		assert displayed
	end

	#Click on dummy module
	#Check wether a module has been added
	test "add a module" do
		els = @wait.until { @driver.find_elements(:class, "inactive") }
		displayed = false
		for el_pot in els
			if el_pot.displayed?
				el = el_pot
				break
			end
		end
		if el and @wait.until { el.displayed? }
			el.click
			newmodule = @wait.until { @driver.find_element(:class, "module-hitbox") }
			displayed = @wait.until { newmodule.displayed? } 
		end
		assert displayed
	end
=end

	#Click on Action History Pane
	#Check if pane showed up
	test "view the actionhistory pane" do
		el = @wait.until { @driver.find_element(:class, "pane-button") }
		pane = @wait.until { @driver.find_element(:class, "pane-left") }
		assert_equal "pane pane-left extended", pane.attribute("class")
		el.click
		assert_equal "pane pane-left", pane.attribute("class")
	end

end