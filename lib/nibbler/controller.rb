module Nibbler
  class Controller < UIViewController
    attr_accessor :parent

    def alert(msg)
      Alert.show(msg)
    end

    # def self.button(tag,opts={})
    #   NSLog "Registering button##{tag}"
    #   opts[:tag] = tag
    #   (@button_specs ||= []) << opts
    # end

    def self.nav_bar(selector={},opts=nil, &block)
      if opts.nil? && selector.kind_of?(Hash)
        opts = selector
        selector = UINavigationBar
      end

      NSLog "Registering nav_bar##{selector}"
      opts[:selector] = selector
      opts[:type] = NavBar
      opts[:block] = block if block_given?
      (@view_specs ||= []) << opts
    end

    # def self.text_field(tag,opts={})
    #   NSLog "Registering text_field##{tag}"
    #   opts[:tag] = tag
    #   (@text_field_specs ||=[]) << opts
    # end

    def viewWillAppear(animatede) #viewDidLoad
      super    
      specs = self.class.instance_variable_get('@view_specs') || [] 
      specs.each do |spec|
        NSLog "Wiring #{spec[:type]}##{spec[:selector]}"
      end
      # specs = self.class.instance_variable_get('@button_specs') || [] 
      # specs.each do |spec|
      #   NSLog "Wiring button##{spec[:tag]} to ##{spec[:action]}"
      #   b = Button.new self, spec[:tag]
      #   b.action = spec[:action]
      #   (@controls ||= []) << b
      # end

      # specs = self.class.instance_variable_get('@nav_bar_specs') || [] 
      # NSLog "#{specs.count} NavBar specs..."
      # specs.each do |spec|
      #   NSLog "Wiring nav_bar##{spec[:selector]}"
      #   b = NavBar.new self, spec[:selector]
      #   spec[:block].call(b) unless spec[:block].nil?
      #   (@controls ||= []) << b
      # end      

      # self.class.instance_variable_get('@text_field_specs').each do |spec|
      #   NSLog "Wiring text_field##{spec[:tag]} named @#{spec[:named]}"
      #   t = TextField.new self, spec[:tag]
      #   NSLog "Setting @#{spec[:named]} on #{self.class}"
      #   self.instance_variable_set("@#{spec[:named]}", t) unless spec[:named].nil? || spec[:named] == ''
      #   (@controls ||= []) << t
      # end
    end

    def self.inherited(subclass)
      puts "Controller Subclass: #{subclass}"
      super(subclass)
      subclass.instance_variable_set('@nav_bar_specs', @nav_bar_specs.dup) if @nav_bar_specs
    end

    def transition_to(target, opts={})
      view = target.kind_of?(Class) ? init_view_from_type(target) : target
      view.parent = self
      yield(view) if block_given?
      presentViewController view, animated: (opts[:animated] || false), completion: nil
    end

    private
    def init_view_from_type(type)
      name = type.name
      name["Controller"] = ""
      type.alloc.initWithNibName name, bundle: nil
    end
  end
end