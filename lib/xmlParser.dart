
import 'package:photo_quest/searchItem.dart';
import 'package:xml/xml.dart';
/*
* Parses to the XML response from K-samsök. Other parameters may be included such as a count of how many records are found.
* */

class XMLParser {
  static const String RECORD = "record";
  static const String TITLE = "pres:itemLabel";
  static const String DESCRIPTION = "pres:description";
  static const String TYPE = "pres:type";
  static const String DATE = "pres:timeLabel";
  static const String PLACE = "pres:placeLabel";
  static const String COORDINATES = "gml:coordinates";
  Set<SearchItem> items = {};

  void parse(XmlDocument doc) {
    List<XmlNode> input = doc.children;
        if (input.isNotEmpty) {
          final records = doc.findAllElements(RECORD);    //XML document divides into nodes and elements, in Samsök the heirarchy is "<record>
          for (var record in records) {
                    SearchItem item = SearchItem();
                    record.findAllElements(TYPE).forEach((type) {item.setType(type.text);}); //there's only one of these per record, so findAll only returns one
                    record.findAllElements(TITLE).forEach((title) {item.setTitle(title.text);});//same for the rest
                    record.findAllElements(DESCRIPTION).forEach((desc){item.setDescription(desc.text.replaceAll("\n", " ").replaceAll("  ", " ").trim());});
                    record.findAllElements(PLACE).forEach((place) {item.setPlaceLabel(place.text.replaceAll("\n", " ").replaceAll("  ", "").trim());});
                    record.findAllElements(DATE).forEach((date) {item.setTimeLabel(date.text);});
                    record.findAllElements(COORDINATES).forEach((coord) {item.setCoordinates(coord.text.replaceAll(" ", "").replaceAll("\n", ""));});
                    if (item.itemCoordinates.isNotEmpty &&
                        item.itemTimeLabel.isNotEmpty)items.add(item);
                 }
        }
      }
  Set<SearchItem> getItems(){
    return items;
  }
  }
