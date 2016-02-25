# Common fixes for editors that use 
# REXML
class CustomPrinter < REXML::Formatters::Pretty
  # Custom sorting of Storyboard element attributes.
  # In order to prevent massive diffs in Storyboard files
  # after flight, we need to try to match the Xcode
  # XML generator as closely as possible.
  #
  # One big issue is the ordering of XML element attributes.
  # Here we attempt to match the attribute ordering for each type
  # of Storyboard element.
  #
  def write_element(elm, out)
    att = elm.attributes

    class <<att
      # Alias old method 
      alias _each_attribute each_attribute

      # Redefine the each_attribute method to call our sorting
      # method
      def each_attribute(&b)
        to_enum(:_each_attribute)
          .sort_by {|x| xcode_index_for(x) }
          .each(&b)
      end

      # Define the order for each type of Xcode element
      def xcode_index_for(attr)
        element_type = attr.element.name
        
        case element_type
        when 'userDefinedRuntimeAttribute'
          index = ['type','keyPath','value'].index(attr.name) || attr.name.length
        when 'color'
          index = ['key', 'white', 'alpha', 'colorSpace', 'customColorSpace'].index(attr.name) || attr.name.length
        when 'placeholder'
          index = ['placeholderIdentifier', 'id', 'sceneMemberID'].index(attr.name) || attr.name.length
        when 'fontDescription'
          index = ['key', 'type', 'pointSize'].index(attr.name) || attr.name.length
        when 'rect'
          index = ['key', 'x', 'y', 'width', 'height'].index(attr.name) || attr.name.length
        when 'label'
          index = ['opaque', 'userInteractionEnabled', 'contentMode', 
                   'horizontalHuggingPriority', 'verticalHuggingPriority', 
                   'misplaced', 'textAlignment', 'lineBreakMode', 'numberOfLines', 
                   'baselineAdjustment', 'minimumScaleFactor', 
                   'translatesAutoresizingMaskIntoConstraints', 'id', 
                   'customClass'].index(attr.name) || attr.name.length
        when 'viewController'
          index = ['id', 'customClass', 'customModule', 
                   'customModuleProvider', 'sceneMemberID'].index(attr.name) || attr.name.length
        when 'viewControllerLayoutGuide'
          index = ['type', 'id'].index(attr.name) || attr.name.length
        when 'view'
          index = ['key', 'contentMode', 'id'].index(attr.name) || attr.name.length
        when 'autoresizingMask'
          index = ['key', 'widthSizable', 'heightSizable'].index(attr.name) || attr.name.length
        when 'document'
          index = ['type', 'version', 'toolsVersion', 'systemVersion', 
                   'targetRuntime', 'propertyAccessControl', 'useAutolayout', 
                   'useTraitCollections', 'initialViewController'].index(attr.name) || attr.name.length
        else
          index = attr.name
        end
        index
      end
    end
    super(elm, out)
  end

  # This genious is here to stop the damn thing from wrapping
  # lines over 80 chars long >.<
  #
  # Source:
  #   http://stackoverflow.com/questions/4203180/rexml-is-wrapping-long-lines-how-do-i-switch-that-off
  #
  def write_text( node, output )
    s = node.to_s()

    #The Pretty formatter code mistakenly used 80 instead of the @width variable
    #s = wrap(s, 80-@level)
    s = wrap(s, @width-@level)

    s = indent_text(s, @level, " ", true)
    output << (' '*@level + s)
  end
end
