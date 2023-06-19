/*
  Copyright (C) 2003  Know Gate S.L. All rights reserved.
                      C/Oña, 107 1º2 28050 Madrid (Spain)

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions
  are met:

  1. Redistributions of source code must retain the above copyright
     notice, this list of conditions and the following disclaimer.

  2. The end-user documentation included with the redistribution,
     if any, must include the following acknowledgment:
     "This product includes software parts from hipergate
     (http://www.hipergate.org/)."
     Alternately, this acknowledgment may appear in the software itself,
     if and wherever such third-party acknowledgments normally appear.

  3. The name hipergate must not be used to endorse or promote products
     derived from this software without prior written permission.
     Products derived from this software may not be called hipergate,
     nor may hipergate appear in their name, without prior written
     permission.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

  You should have received a copy of hipergate License with this code;
  if not, visit http://www.hipergate.org or mail to info@hipergate.org
*/

package com.knowgate.dataxslt;

import org.w3c.dom.Node;

import dom.DOMSubDocument;

/**
 * Image element into a Block of a PageSet.
 *
 * @author Sergio Montoro Ten
 * @version 1.0
 */
public class Image extends DOMSubDocument {

  /**
   * @param oRefNode DOMDocument Node holding &lt;image&gt; element.
   */

  public Image(Node oRefNode) {
    super(oRefNode);
  }

  // ----------------------------------------------------------

  public String id() {
    Node oItem = oNode.getAttributes().getNamedItem("id");

    if (null==oItem)
      return null;
    else
      return oItem.getNodeValue();
  } // id()

  // ----------------------------------------------------------

  public String url() {
    if (null==getElement("url"))
      return "";
    else
      return getElement("url");
  } // id()

  public String path() {
    if (null==getElement("path"))
      return "";
    else
      return getElement("path");
  } // id()

  public String width() {
    if (null==getElement("width"))
      return "";
    else
      return getElement("width");
  } // id()

  public String height() {
    if (null==getElement("height"))
      return "";
    else
      return getElement("height");
  } // id()

  public String alt() {
    if (null==getElement("alt"))
      return "";
    else
      return getElement("alt");
  } // id()

  // ----------------------------------------------------------
}