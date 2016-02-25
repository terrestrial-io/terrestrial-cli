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

      def _xcode_get_index(order, attr)
        order.index(attr.name) || attr.name.length
      end

      # Define the order for each type of Xcode element
      def xcode_index_for(attr)
        element_type = attr.element.name
        
        case element_type
        when 'userDefinedRuntimeAttribute'
          index = _xcode_get_index(['type','keyPath','value'], attr)
        when 'color'
          index = _xcode_get_index(['key', 'red', 'green', 'blue', 'white', 'alpha', 'colorSpace', 
                                    'customColorSpace'], attr)
        when 'placeholder'
          index = _xcode_get_index(['placeholderIdentifier', 'id', 'userLabel', 'sceneMemberID'], attr)
        when 'fontDescription'
          index = _xcode_get_index(['key', 'type', 'name', 'family', 'pointSize'], attr)
        when 'rect'
          index = _xcode_get_index(['key', 'x', 'y', 'width', 'height'], attr)
        when 'label'
          index = _xcode_get_index(['opaque', 'multipleTouchEnabled', 'userInteractionEnabled', 'contentMode', 
                                    'horizontalHuggingPriority', 'verticalHuggingPriority', 'text',
                                    'misplaced', 'textAlignment', 'lineBreakMode', 'numberOfLines', 
                                    'baselineAdjustment', 'adjustsFontSizeToFit', 'minimumScaleFactor', 
                                    'translatesAutoresizingMaskIntoConstraints', 'id', 
                                    'customClass'], attr)
        when 'button'
          index = _xcode_get_index(['opaque', 'contentMode', 'contentHorizontalAlignment', 
                                    'contentVerticalAlignment', 'buttonType', 'lineBreakMode', 
                                    'id'], attr)
        when 'viewController'
          index = _xcode_get_index(['storyboardIdentifier', 'id', 'customClass', 'customModule', 
                   'customModuleProvider', 'sceneMemberID'], attr)
        when 'viewControllerLayoutGuide'
          index = _xcode_get_index(['type', 'id'], attr)
        when 'view'
          index = _xcode_get_index(['autoresizesSubviews','clipsSubviews', 'alpha', 'key', 
                                    'contentMode', 'id'], attr)
        when 'autoresizingMask'
          index = _xcode_get_index(['key', 'flexibleMaxX', 'flexibleMaxY', 'widthSizable', 
                                    'heightSizable'], attr)
        when 'document'
          index = _xcode_get_index(['type', 'version', 'toolsVersion', 'systemVersion', 
                                    'targetRuntime', 'propertyAccessControl', 'useAutolayout', 
                                    'useTraitCollections', 'initialViewController'], attr)
        when 'document'
          index = _xcode_get_index(['type', 'version', 'toolsVersion', 'systemVersion', 
                                    'targetRuntime', 'propertyAccessControl', 'useAutolayout', 
                                    'useTraitCollections', 'initialViewController'], attr)
        when 'image'
          index = _xcode_get_index(['name', 'width', 'height'], attr)
        when 'imageView'
          index = _xcode_get_index(['clipsSubviews', 'userInteractionEnabled', 'alpha', 
                                    'contentMode', 'horizontalHuggingPriority', 
                                    'verticalHuggingPriority', 'image', 'id'], attr)
        when 'segue'
          index = _xcode_get_index(['destination', 'kind', 'relationship', 'id'], attr)
        when 'navigationBar'
          index = _xcode_get_index(['key', 'contentMode', 'id'], attr)
        when 'navigationItem'
          index = _xcode_get_index(['key', 'title', 'id'], attr)
        when 'navigationController'
          index = _xcode_get_index(['storyboardIdentifier', 'automaticallyAdjustsScrollViewInsets', 
                                    'id', 'sceneMemberID'], attr)
        when 'outlet'
          index = _xcode_get_index(['property', 'destination', 'id'], attr)
        when 'action'
          index = _xcode_get_index(['selector', 'destination', 'id'], attr)
        when 'barButtonItem'
          index = _xcode_get_index(['key', 'title', 'id'], attr)
        when 'tableViewController'
          index = _xcode_get_index(['restorationIdentifier', 'storyboardIdentifier', 'id', 
                                    'customClass', 'sceneMemberID'], attr)
        when 'tableView'
          index = _xcode_get_index(['key', 'clipsSubviews', 'contentMode', 'alwaysBounceVertical', 
                                    'dataMode', 'style', 'separatorStyle', 'rowHeight', 
                                    'sectionHeaderHeight', 'sectionFooterHeight', 'id'], attr)
        when 'tableViewCellContentView'
          index = _xcode_get_index(['key', 'opaque', 'clipsSubviews', 'multipleTouchEnabled', 
                                    'contentMode', 'tableViewCell', 'id'], attr)
        when 'tableViewCell'
          index = _xcode_get_index(['key', 'opaque', 'clipsSubviews', 'multipleTouchEnabled', 
                                    'contentMode', 'selectionStyle', 'accessoryType', 'indentationWidth', 
                                    'textLabel', 'detailTextLabel', 'rowHeight', 'style', 'id'], attr)
        when 'size'
          index = _xcode_get_index(['key', 'width', 'height'], attr)
        when 'textField'
          index = _xcode_get_index(['opaque', 'clipsSubviews', 'contentMode', 'contentHorizontalAlignment', 
                                    'contentVerticalAlignment', 'text', 'borderStyle', 'placeholder', 
                                    'textAlignment', 'minimumFontSize', 'id'], attr)
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
