# Common fixes for editors that use 
# REXML
class CustomPrinter < REXML::Formatters::Pretty
  # The point of this little thing is to keep
  # the order of attributes when we flush the 
  # storyboard back to disk.
  # We do this to avoid massive git diffs.
  # Turns out that xcode is quite good at updating
  # and reverting our formating changes though.
  #
  # Source: 
  #   http://stackoverflow.com/questions/574724/rexml-preserve-attributes-order
  #
  #   fmt = OrderedAttributes.new
  #   fmt.write(xmldoc, $stdout)
  #
  # def write_element(elm, out)
  #   att = elm.attributes
  #   class <<att
  #     alias _each_attribute each_attribute

  #     def each_attribute(&b)
  #       to_enum(:_each_attribute).sort_by {|x| x.name}.each(&b)
  #     end
  #   end
  #   super(elm, out)
  # end

  # This genious is here to stop the damn thing from wrapping
  # lines over 80 chars long >.<
  #
  # Source:
  #   http://stackoverflow.com/questions/4203180/rexml-is-wrapping-long-lines-how-do-i-switch-that-off
  #
  def write_text( node, output )
    s = node.to_s()
    s.gsub!(/\s/,' ')
    s.squeeze!(" ")

    #The Pretty formatter code mistakenly used 80 instead of the @width variable
    #s = wrap(s, 80-@level)
    s = wrap(s, @width-@level)

    s = indent_text(s, @level, " ", true)
    output << (' '*@level + s)
  end
end
