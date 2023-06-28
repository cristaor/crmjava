/*****************************************************************

	ActiveWidgets Grid 1.0.2 (GPL).
	Copyright (C) 2003-2005 ActiveWidgets Ltd. All Rights Reserved. 
	http://www.activewidgets.com/

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

*****************************************************************/
if (!window.Active) {
  var Active = {}
}
if (!Active.System) {
  Active.System = {}
}
if (!Active.HTML) {
  Active.HTML = {}
}
if (!Active.Templates) {
  Active.Templates = {}
}
if (!Active.Formats) {
  Active.Formats = {}
}
if (!Active.HTTP) {
  Active.HTTP = {}
}
if (!Active.Text) {
  Active.Text = {}
}
if (!Active.XML) {
  Active.XML = {}
}
if (!Active.Controls) {
  Active.Controls = {}
}(function () {
  if (!window.HTMLElement) {
    return
  }
  var element = HTMLElement.prototype;
  element.__proto__ = {
    __proto__: element.__proto__
  };
  element = element.__proto__;
  var capture = ["click", "mousedown", "mouseup", "mousemove", "mouseover", "mouseout"];
  element.setCapture = function () {
    var self = this;
    var flag = false;
    this._capture = function (e) {
      if (flag) {
        return
      }
      flag = true;
      var event = document.createEvent("MouseEvents");
      event.initMouseEvent(e.type, e.bubbles, e.cancelable, e.view, e.detail, e.screenX, e.screenY, e.clientX, e.clientY, e.ctrlKey, e.altKey, e.shiftKey, e.metaKey, e.button, e.relatedTarget);
      self.dispatchEvent(event);
      flag = false
    };
    for (var i = 0; i < capture.length; i++) {
      window.addEventListener(capture[i], this._capture, true)
    }
  };
  element.releaseCapture = function () {
    for (var i = 0; i < capture.length; i++) {
      window.removeEventListener(capture[i], this._capture, true)
    }
    this._capture = null
  };
  element.attachEvent = function (name, handler) {
    if (typeof handler != "function") {
      return
    }
    var nsName = name.replace(/^on/, "");
    var nsHandler = function (event) {
        window.event = event;
        handler();
        window.event = null
      };
    handler[name] = nsHandler;
    this.addEventListener(nsName, nsHandler, false)
  };
  element.detachEvent = function (name, handler) {
    if (typeof handler != "function") {
      return
    }
    var nsName = name.replace(/^on/, "");
    this.removeEventListener(nsName, handler[name], false);
    handler[name] = null
  };
  var getClientWidth = function () {
      return this.offsetWidth - 20
    };
  var getClientHeight = function () {
      return this.offsetHeight - 20
    };
  element.__defineGetter__("clientWidth", getClientWidth);
  element.__defineGetter__("clientHeight", getClientHeight);
  var getRuntimeStyle = function () {
      return this.style
    };
  element.__defineGetter__("runtimeStyle", getRuntimeStyle);
  var cs = CSSStyleDeclaration.prototype;
  cs.__proto__ = {
    __proto__: cs.__proto__
  };
  cs = cs.__proto__;
  cs.__defineGetter__("paddingTop", function () {
    return this.getPropertyValue("padding-top")
  });
  var getCurrentStyle = function () {
      return document.defaultView.getComputedStyle(this, "")
    };
  element.__defineGetter__("currentStyle", getCurrentStyle);
  var setOuterHtml = function (s) {
      var range = this.ownerDocument.createRange();
      range.setStartBefore(this);
      var fragment = range.createContextualFragment(s);
      this.parentNode.replaceChild(fragment, this)
    };
  element.__defineSetter__("outerHTML", setOuterHtml)
})();
(function () {
  if (!window.Event) {
    return
  }
  var event = Event.prototype;
  event.__proto__ = {
    __proto__: event.__proto__
  };
  event = event.__proto__;
  if (!event) {
    return
  }
  var getSrcElement = function () {
      return (this.target.nodeType == 3) ? this.target.parentNode : this.target
    };
  event.__defineGetter__("srcElement", getSrcElement);
  var setReturnValue = function (value) {
      if (!value) {
        this.preventDefault()
      }
    };
  event.__defineSetter__("returnValue", setReturnValue)
})();
(function () {
  if (!window.CSSStyleSheet) {
    return
  }
  var stylesheet = CSSStyleSheet.prototype;
  stylesheet.__proto__ = {
    __proto__: stylesheet.__proto__
  };
  stylesheet = stylesheet.__proto__;
  stylesheet.addRule = function (selector, rule) {
    this.insertRule(selector + "{" + rule + "}", this.cssRules.length)
  };
  stylesheet.__defineGetter__("rules", function () {
    return this.cssRules
  })
})();
(function () {
  if (!window.XMLHttpRequest) {
    return
  }
  var ActiveXObject = function (type) {
      ActiveXObject[type](this)
    };
  ActiveXObject["MSXML2.DOMDocument"] = function (obj) {
    obj.setProperty = function () {};
    obj.load = function (url) {
      var xml = this;
      var async = this.async ? true : false;
      var request = new XMLHttpRequest();
      request.open("GET", url, async);
      request.overrideMimeType("text/xml");
      if (async) {
        request.onreadystatechange = function () {
          xml.readyState = request.readyState;
          if (request.readyState == 4) {
            xml.documentElement = request.responseXML.documentElement;
            xml.firstChild = xml.documentElement;
            request.onreadystatechange = null
          }
          if (xml.onreadystatechange) {
            xml.onreadystatechange()
          }
        }
      }
      this.parseError = {
        errorCode: 0,
        reason: "Emulation"
      };
      request.send(null);
      this.readyState = request.readyState;
      if (request.responseXML && !async) {
        this.documentElement = request.responseXML.documentElement;
        this.firstChild = this.documentElement
      }
    }
  };
  ActiveXObject["MSXML2.XMLHTTP"] = function (obj) {
    obj.open = function (method, url, async) {
      this.request = new XMLHttpRequest();
      this.request.open(method, url, async)
    };
    obj.send = function (data) {
      this.request.send(data)
    };
    obj.setRequestHeader = function (name, value) {
      this.request.setRequestHeader(name, value)
    };
    obj.__defineGetter__("readyState", function () {
      return this.request.readyState
    });
    obj.__defineGetter__("responseXML", function () {
      return this.request.responseXML
    });
    obj.__defineGetter__("responseText", function () {
      return this.request.responseText
    })
  }
})();
(function () {
  if (!window.XPathEvaluator) {
    return
  }
  var xpath = new XPathEvaluator();
  var element = Element.prototype;
  element.__proto__ = {
    __proto__: element.__proto__
  };
  element = element.__proto__;
  var attribute = Attr.prototype;
  attribute.__proto__ = {
    __proto__: attribute.__proto__
  };
  attribute = attribute.__proto__;
  var txt = Text.prototype;
  txt.__proto__ = {
    __proto__: txt.__proto__
  };
  txt = txt.__proto__;
  var doc = Document.prototype;
  doc.__proto__ = {
    __proto__: doc.__proto__
  };
  doc = doc.__proto__;
  doc.loadXML = function (text) {
    var parser = new DOMParser;
    var newDoc = parser.parseFromString(text, "text/xml");
    this.replaceChild(newDoc.documentElement, this.documentElement)
  };
  doc.setProperty = function (name, value) {
    if (name == "SelectionNamespaces") {
      namespaces = {};
      var a = value.split(" xmlns:");
      for (var i = 1; i < a.length; i++) {
        var s = a[i].split("=");
        namespaces[s[0]] = s[1].replace(/\"/g, "")
      }
      this._ns = {
        lookupNamespaceURI: function (prefix) {
          return namespaces[prefix]
        }
      }
    }
  };
  doc._ns = {
    lookupNamespaceURI: function () {
      return null
    }
  };
  doc.selectNodes = function (path) {
    var result = xpath.evaluate(path, this, this._ns, 7, null);
    var i, nodes = [];
    for (i = 0; i < result.snapshotLength; i++) {
      nodes[i] = result.snapshotItem(i)
    }
    return nodes
  };
  doc.selectSingleNode = function (path) {
    return xpath.evaluate(path, this, this._ns, 9, null).singleNodeValue
  };
  element.selectNodes = function (path) {
    var result = xpath.evaluate(path, this, this.ownerDocument._ns, 7, null);
    var i, nodes = [];
    for (i = 0; i < result.snapshotLength; i++) {
      nodes[i] = result.snapshotItem(i)
    }
    return nodes
  };
  element.selectSingleNode = function (path) {
    return xpath.evaluate(path, this, this.ownerDocument._ns, 9, null).singleNodeValue
  };
  element.__defineGetter__("text", function () {
    var i, a = [],
      nodes = this.childNodes,
      length = nodes.length;
    for (i = 0; i < length; i++) {
      a[i] = nodes[i].text
    }
    return a.join("")
  });
  attribute.__defineGetter__("text", function () {
    return this.nodeValue
  });
  txt.__defineGetter__("text", function () {
    return this.nodeValue
  })
})();
Active.System.Object = function () {};
Active.System.Object.subclass = function () {
  var constructor = function () {
      this.init()
    };
  for (var i in this) {
    constructor[i] = this[i]
  }
  constructor.prototype = new this();
  constructor.superclass = this;
  return constructor
};
Active.System.Object.handle = function (error) {
  throw (error)
};
Active.System.Object.create = function () {
  var obj = this.prototype;
  obj.clone = function () {
    if (this._clone.prototype !== this) {
      this._clone = function () {
        this.init()
      };
      this._clone.prototype = this
    }
    return new this._clone()
  };
  obj._clone = function () {};
  obj.init = function () {};
  obj.handle = function (error) {
    throw (error)
  };
  obj.timeout = function (handler, delay) {
    var self = this;
    var wrapper = function () {
        handler.call(self)
      };
    return window.setTimeout(wrapper, delay ? delay : 0)
  };
  obj.toString = function () {
    return ""
  }
};
Active.System.Object.create();
Active.System.Model = Active.System.Object.subclass();
Active.System.Model.create = function () {
  var obj = this.prototype;
  var join = function () {
      var i, s = arguments[0];
      for (i = 1; i < arguments.length; i++) {
        s += arguments[i].substr(0, 1).toUpperCase() + arguments[i].substr(1)
      }
      return s
    };
  obj.defineProperty = function (name, value) {
    var _getProperty = join("get", name);
    var _setProperty = join("set", name);
    var _property = "_" + name;
    var getProperty = function () {
        return this[_property]
      };
    this[_setProperty] = function (value) {
      if (typeof value == "function") {
        this[_getProperty] = value
      } else {
        this[_getProperty] = getProperty;
        this[_property] = value
      }
    };
    this[_setProperty](value)
  };
  var get = {};
  var set = {};
  obj.getProperty = function (name, a, b, c) {
    if (!get[name]) {
      get[name] = join("get", name)
    }
    return this[get[name]](a, b, c)
  };
  obj.setProperty = function (name, value, a, b, c) {
    if (!set[name]) {
      set[name] = join("set", name)
    }
    return this[set[name]](value, a, b, c)
  };
  obj.isReady = function () {
    return true
  }
};
Active.System.Model.create();
Active.System.Format = Active.System.Object.subclass();
Active.System.Format.create = function () {
  var obj = this.prototype;
  obj.valueToText = function (value) {
    return value
  };
  obj.dataToValue = function (data) {
    return data
  };
  obj.dataToText = function (data) {
    var value = this.dataToValue(data);
    return this.valueToText(value)
  };
  obj.setErrorText = function (text) {
    this._textError = text
  };
  obj.setErrorValue = function (value) {
    this._valueError = value
  };
  obj.setErrorText("#ERR");
  obj.setErrorValue(NaN)
};
Active.System.Format.create();
Active.System.HTML = Active.System.Object.subclass();
Active.System.HTML.create = function () {
  var obj = this.prototype;
  obj.setTag = function (tag) {
    this._tag = tag
  };
  obj.getTag = function () {
    return this._tag
  };
  obj._tag = "div";
  obj.init = function () {
    if (this.$owner) {
      return
    }
    if (this._parent) {
      return
    }
    this._id = "tag" + this.all.id++;
    this.all[this._id] = this
  };
  obj.getId = function () {
    return this._id
  };
  obj._id = "";
  obj.all = Active.System.all = {
    id: 0
  };
  obj.setId = function (id) {
    this._id = id;
    this.all[this._id] = this
  };
  obj.element = function () {
    var i, docs = this._docs,
      id = this.getId(),
      e;
    for (i = 0; i < docs.length; i++) {
      e = docs[i].getElementById(id);
      if (e) {
        return e
      }
    }
  };
  obj._docs = [document];
  obj.getClass = function (name) {
    var param = "_" + name + "Class";
    var value = this[param];
    return typeof (value) == "function" ? value.call(this) : value
  };
  obj.setClass = function (name, value) {
    var element = this.element();
    if (element) {
      var v = (typeof (value) == "function") ? value.call(this) : value;
      element.className = element.className.replace(new RegExp("(active-" + name + "-\\w+|$)"), " active-" + name + "-" + v + " ");
      if (this.$index !== "") {
        return
      }
    }
    if (this.data) {
      return
    }
    var param = "_" + name + "Class";
    if (this[param] == null) {
      this._classes += " " + name
    }
    this[param] = value;
    this._outerHTML = ""
  };
  obj.refreshClasses = function () {
    var element = this.element();
    if (!element) {
      return
    }
    var s = "",
      classes = this._classes.split(" ");
    for (var i = 1; i < classes.length; i++) {
      var name = classes[i];
      var value = this["_" + name + "Class"];
      if (typeof (value) == "function") {
        value = value.call(this)
      }
      s += "active-" + name + "-" + value + " "
    }
    element.className = s + this.$browser
  };
  obj._classes = "";
  obj.getStyle = function (name) {
    var param = "_" + name + "Style";
    var value = this[param];
    return typeof (value) == "function" ? value.call(this) : value
  };
  obj.setStyle = function (name, value) {
    var element = this.element();
    if (element) {
      element.style[name] = value
    }
    if (this.data) {
      return
    }
    var param = "_" + name + "Style";
    if (this[param] == null) {
      this._styles += " " + name
    }
    this[param] = value;
    this._outerHTML = ""
  };
  obj._styles = "";
  obj.getAttribute = function (name) {
    try {
      var param = "_" + name + "Attribute";
      var value = this[param];
      return typeof (value) == "function" ? value.call(this) : value
    } catch (error) {
      this.handle(error)
    }
  };
  obj.setAttribute = function (name, value) {
    try {
      var param = "_" + name + "Attribute";
      if (typeof this[param] == "undefined") {
        this._attributes += " " + name
      }
      if (specialAttributes[name] && (typeof value == "function")) {
        this[param] = function () {
          return value.call(this) ? true : null
        }
      } else {
        this[param] = value
      }
      this._outerHTML = ""
    } catch (error) {
      this.handle(error)
    }
  };
  obj._attributes = "";
  var specialAttributes = {
    checked: true,
    disabled: true,
    hidefocus: true,
    readonly: true
  };
  obj.getEvent = function (name) {
    try {
      var param = "_" + name + "Event";
      var value = this[param];
      return value
    } catch (error) {
      this.handle(error)
    }
  };
  obj.setEvent = function (name, value) {
    try {
      var param = "_" + name + "Event";
      if (this[param] == null) {
        this._events += " " + name
      }
      this[param] = value;
      this._outerHTML = ""
    } catch (error) {
      this.handle(error)
    }
  };
  obj._events = "";
  obj.getContent = function (name) {
    try {
      var split = name.match(/^(\w+)\W(.+)$/);
      if (split) {
        var ref = this.getContent(split[1]);
        return ref.getContent(split[2])
      } else {
        var param = "_" + name + "Content";
        var value = this[param];
        if ((typeof value == "object") && (value._parent != this)) {
          value = value.clone();
          value._parent = this;
          value._id = this._id + "/" + name;
          this[param] = value
        }
        return value
      }
    } catch (error) {
      this.handle(error)
    }
  };
  obj.setContent = function (name, value) {
    try {
      if (arguments.length == 1) {
        this._content = "";
        if (typeof name == "object") {
          for (var i in name) {
            if (typeof (i) == "string") {
              this.setContent(i, name[i])
            }
          }
        } else {
          this.setContent("html", name)
        }
      } else {
        var split = name.match(/^(\w+)\W(.+)$/);
        if (split) {
          var ref = this.getContent(split[1]);
          ref.setContent(split[2], value);
          this._innerHTML = "";
          this._outerHTML = ""
        } else {
          var param = "_" + name + "Content";
          if (this[param] == null) {
            this._content += " " + name
          }
          if (typeof value == "object") {
            value._parent = this;
            value._id = this._id + "/" + name
          }
          this[param] = value;
          this._innerHTML = "";
          this._outerHTML = ""
        }
      }
    } catch (error) {
      this.handle(error)
    }
  };
  obj._content = "";
  obj.$index = "";
  var getParamStr = function (i) {
      return "{#" + i + "}"
    };
  obj.innerHTML = function () {
    try {
      if (this._innerHTML) {
        return this._innerHTML
      }
      this._innerParamLength = 0;
      var i, j, name, value, param1, param2, html, item, s = "";
      var content = this._content.split(" ");
      for (i = 1; i < content.length; i++) {
        name = content[i];
        value = this["_" + name + "Content"];
        if (typeof (value) == "function") {
          param = getParamStr(this._innerParamLength++);
          this[param] = value;
          s += param
        } else if (typeof (value) == "object") {
          item = value;
          html = item.outerHTML().replace(/\{id\}/g, "{id}/" + name);
          for (j = item._outerParamLength - 1; j >= 0; j--) {
            param1 = getParamStr(j);
            param2 = getParamStr(this._innerParamLength + j);
            if (param1 != param2) {
              html = html.replace(param1, param2)
            }
            this[param2] = item[param1]
          }
          this._innerParamLength += item._outerParamLength;
          s += html
        } else {
          s += value
        }
      }
      this._innerHTML = s;
      return s
    } catch (error) {
      this.handle(error)
    }
  };
  obj.outerHTML = function () {
    try {
      if (this._outerHTML) {
        return this._outerHTML
      }
      var innerHTML = this.innerHTML();
      this._outerParamLength = this._innerParamLength;
      if (!this._tag) {
        return innerHTML
      }
      var i, tmp, name, value, param;
      var html = "<" + this._tag + " id=\"{id}\"";
      tmp = "";
      var classes = this._classes.split(" ");
      for (i = 1; i < classes.length; i++) {
        name = classes[i];
        value = this["_" + name + "Class"];
        if (typeof (value) == "function") {
          param = getParamStr(this._outerParamLength++);
          this[param] = value;
          value = param
        }
        tmp += "active-" + name + "-" + value + " "
      }
      if (tmp) {
        html += " class=\"" + tmp + this.$browser + "\""
      }
      tmp = "";
      var styles = this._styles.split(" ");
      for (i = 1; i < styles.length; i++) {
        name = styles[i];
        value = this["_" + name + "Style"];
        if (typeof (value) == "function") {
          param = getParamStr(this._outerParamLength++);
          this[param] = value;
          value = param
        }
        tmp += name + ":" + value + ";"
      }
      if (tmp) {
        html += " style=\"" + tmp + "\""
      }
      tmp = "";
      var attributes = this._attributes.split(" ");
      for (i = 1; i < attributes.length; i++) {
        name = attributes[i];
        value = this["_" + name + "Attribute"];
        if (typeof (value) == "function") {
          param = getParamStr(this._outerParamLength++);
          this[param] = value;
          value = param
        } else if (specialAttributes[name] && !value) {
          value = null
        }
        if (value !== null) {
          tmp += " " + name + "=\"" + value + "\""
        }
      }
      html += tmp;
      tmp = "";
      var events = this._events.split(" ");
      for (i = 1; i < events.length; i++) {
        name = events[i];
        value = this["_" + name + "Event"];
        if (typeof (value) == "function") {
          value = "dispatch(event,this)"
        }
        tmp += " " + name + "=\"" + value + "\""
      }
      html += tmp;
      html += ">" + innerHTML + "</" + this._tag + ">";
      this._outerHTML = html;
      return html
    } catch (error) {
      this.handle(error)
    }
  };
  obj.toString = function () {
    try {
      var i, s = this._outerHTML;
      if (!s) {
        s = this.outerHTML()
      }
      s = s.replace(/\{id\}/g, this.getId());
      var max = this._outerParamLength;
      for (i = 0; i < max; i++) {
        var param = "{#" + i + "}";
        var value = this[param]();
        if (value === null) {
          value = "";
          param = specialParams[i];
          if (!param) {
            param = getSpecialParamStr(i)
          }
        }
        s = s.replace(param, value)
      }
      return s
    } catch (error) {
      this.handle(error)
    }
  };
  var specialParams = [];

  function getSpecialParamStr(i) {
    return (specialParams[i] = new RegExp("[\\w\\x2D]*=?:?\\x22?\\{#" + i + "\\}[;\\x22]?"))
  }
  obj.refresh = function () {
    try {
      var element = this.element();
      if (element) {
        element.outerHTML = this.toString()
      }
    } catch (error) {
      this.handle(error)
    }
  };
  obj.$browser = "";
  if (window.__defineGetter__) {
    obj.$browser = "gecko"
  }
  if (navigator.userAgent.match("Opera")) {
    obj.$browser = "opera"
  }
  if (navigator.userAgent.match("Konqueror")) {
    obj.$browser = "khtml"
  }
  if (navigator.userAgent.match("KHTML")) {
    obj.$browser = "khtml"
  }
};
Active.System.HTML.create();
var dispatch = function (event, element) {
    var parts = element.id.split("/");
    var tag = parts[0].split(".");
    var obj = Active.System.all[tag[0]];
    var type = "_on" + event.type + "Event";
    var i;
    for (i = 1; i < tag.length; i++) {
      var params = tag[i].split(":");
      obj = obj.getTemplate.apply(obj, params)
    }
    var target = obj;
    for (i = 1; i < parts.length; i++) {
      target = target.getContent(parts[i])
    }
    if (window.HTMLElement) {
      window.event = event
    }
    target[type].call(obj, event);
    if (window.HTMLElement) {
      window.event = null
    }
    return
  };
var mouseover = function (element, name) {
    try {
      element.className += " " + name
    } catch (error) {}
  };
var mouseout = function (element, name) {
    try {
      element.className = element.className.replace(RegExp(" " + name, "g"), "")
    } catch (error) {}
  };
Active.System.Template = Active.System.HTML.subclass();
Active.System.Template.create = function () {
  var obj = this.prototype;
  var _super = this.superclass.prototype;
  var _pattern = /^(\w+)\W(.+)$/;
  var join = function () {
      var i, s = arguments[0];
      for (i = 1; i < arguments.length; i++) {
        s += arguments[i].substr(0, 1).toUpperCase() + arguments[i].substr(1)
      }
      return s
    };
  obj.getProperty = function (name, a, b, c) {
    if (name.match(_pattern)) {
      var getProperty = join("get", RegExp.$1, "property");
      if (this[getProperty]) {
        return this[getProperty](RegExp.$2, a, b, c)
      }
    }
  };
  obj.setProperty = function (name, value, a, b, c) {
    if (name.match(_pattern)) {
      var setProperty = join("set", RegExp.$1, "property");
      if (this[setProperty]) {
        return this[setProperty](RegExp.$2, value, a, b, c)
      }
    }
  };
  obj.getModel = function (name) {
    var getModel = join("get", name, "model");
    return this[getModel]()
  };
  obj.setModel = function (name, model) {
    var setModel = join("set", name, "model");
    return this[setModel](model)
  };
  obj.defineTemplate = function (name, template) {
    var ref = "_" + name + "Template";
    var get = join("get", name, "template");
    var set = join("set", name, "template");
    var getDefault = join("default", name, "template");
    var name1 = "." + name;
    var name2 = "." + name + ":";
    this[get] = this[getDefault] = function (index) {
      if (typeof (this[ref]) == "function") {
        return this[ref].call(this, index)
      }
      if (this[ref].$owner != this) {
        this[set](this[ref].clone())
      }
      if (typeof (index) == "undefined") {
        this[ref]._id = this._id + name1
      } else {
        this[ref]._id = this._id + name2 + index
      }
      this[ref].$index = index;
      return this[ref]
    };
    obj[get] = function (a, b, c) {
      return this.$owner[get](a, b, c)
    };
    obj[set] = function (template) {
      this[ref] = template;
      if (template) {
        template.$owner = this
      }
    };
    this[set](template)
  };
  obj.getTemplate = function (name) {
    if (name.match(_pattern)) {
      var get = join("get", RegExp.$1, "template");
      arguments[0] = RegExp.$2;
      var template = this[get]();
      return template.getTemplate.apply(template, arguments)
    } else {
      get = join("get", name, "template");
      var i, args = [];
      for (i = 1; i < arguments.length; i++) {
        args[i - 1] = arguments[i]
      }
      return this[get].apply(this, args)
    }
  };
  obj.setTemplate = function (name, template, index) {
    if (name.match(_pattern)) {
      var get = join("get", RegExp.$1, "template");
      var n = RegExp.$2;
      this[get]().setTemplate(n, template, index)
    } else {
      var set = join("set", name, "template");
      this[set](template, index)
    }
  };
  obj.getAction = function (name) {
    return this["_" + name + "Action"]
  };
  obj.setAction = function (name, value) {
    this["_" + name + "Action"] = value
  };
  obj.action = function (name, source, a, b, c) {
    if (typeof source == "undefined") {
      source = this
    }
    var action = this["_" + name + "Action"];
    if (typeof (action) == "function") {
      action.call(this, source, a, b, c)
    } else if (this.$owner) {
      this.$owner.action(name, source, a, b, c)
    }
  }
};
Active.System.Template.create();
Active.System.Control = Active.System.Template.subclass();
Active.System.Control.create = function () {
  var obj = this.prototype;
  var _super = this.superclass.prototype;
  var _pattern = /^(\w+)\W(.+)$/;
  var join = function () {
      var i, s = arguments[0];
      for (i = 1; i < arguments.length; i++) {
        s += arguments[i].substr(0, 1).toUpperCase() + arguments[i].substr(1)
      }
      return s
    };
  obj.setEvent("oncontextmenu", "return false");
  obj.setEvent("onselectstart", "return false");
  obj.defineModel = function (name) {
    var external = "_" + name + "Model";
    var defineProperty = join("define", name, "property");
    var definePropertyArray = join("define", name, "property", "array");
    var getProperty = join("get", name, "property");
    var setProperty = join("set", name, "property");
    var get = {};
    var set = {};
    var getModel = join("get", name, "model");
    var setModel = join("set", name, "model");
    var updateModel = join("update", name, "model");
    this[defineProperty] = function (property, defaultValue) {
      var _getProperty = join("get", name, property);
      var _setProperty = join("set", name, property);
      var _property = "_" + join(name, property);
      var getPropertyMethod = function () {
          return this[_property]
        };
      this[_getProperty] = getPropertyMethod;
      this[_setProperty] = function (value) {
        if (typeof value == "function") {
          this[_getProperty] = value
        } else {
          if (this[_getProperty] !== getPropertyMethod) {
            this[_getProperty] = getPropertyMethod
          }
          this[_property] = value
        }
        this[updateModel](property)
      };
      this[_setProperty](defaultValue)
    };
    this[getProperty] = function (property, a, b, c) {
      try {
        if (this[external]) {
          return this[external].getProperty(property, a, b, c)
        }
        if (!get[property]) {
          get[property] = join("get", name, property)
        }
        return this[get[property]](a, b, c)
      } catch (error) {
        return this.handle(error)
      }
    };
    this[setProperty] = function (property, value, a, b, c) {
      try {
        if (this[external]) {
          return this[external].setProperty(property, value, a, b, c)
        }
        if (!set[property]) {
          set[property] = join("set", name, property)
        }
        return this[set[property]](value, a, b, c)
      } catch (error) {
        return this.handle(error)
      }
    };
    _super[getProperty] = function (property, a, b, c) {
      if (this[external]) {
        return this[external].getProperty(property, a, b, c)
      }
      return this.$owner[getProperty](property, a, b, c)
    };
    _super[setProperty] = function (property, value, a, b, c) {
      if (this[external]) {
        return this[external].setProperty(property, value, a, b, c)
      }
      return this.$owner[setProperty](property, value, a, b, c)
    };
    this[definePropertyArray] = function (property, defaultValue) {
      var _getProperty = join("get", name, property);
      var _setProperty = join("set", name, property);
      var _getArray = join("get", name, property + "s");
      var _setArray = join("set", name, property + "s");
      var _array = "_" + join(name, property + "s");
      var _getCount = join("get", name, "count");
      var _setCount = join("set", name, "count");
      var getArrayElement = function (index) {
          return this[_array][index]
        };
      var getStaticElement = function () {
          return this[_array]
        };
      var getArray = function () {
          return this[_array].concat()
        };
      var getTempArray = function () {
          var i, a = [],
            max = this[_getCount]();
          for (i = 0; i < max; i++) {
            a[i] = this[_getProperty](i)
          }
          return a
        };
      this[_setProperty] = function (value, index) {
        if (typeof value == "function") {
          this[_getProperty] = value;
          this[_getArray] = getTempArray
        } else if (arguments.length == 1) {
          this[_array] = value;
          this[_getProperty] = getStaticElement;
          this[_getArray] = getTempArray
        } else {
          if (this[_getArray] != getArray) {
            this[_array] = this[_getArray]()
          }
          this[_array][index] = value;
          this[_getProperty] = getArrayElement;
          this[_getArray] = getArray
        }
        this[updateModel](property)
      };
      this[_setArray] = function (value) {
        if (typeof value == "function") {
          this[_getArray] = value
        } else {
          this[_array] = value.concat();
          this[_getProperty] = getArrayElement;
          this[_getArray] = getArray;
          this[_setCount](value.length)
        }
        this[updateModel](property)
      };
      this[_setProperty](defaultValue)
    };
    var proxyPrototype = new Active.System.Model;
    proxyPrototype.getProperty = function (property, a, b, c) {
      return this._target[getProperty](property, a, b, c)
    };
    proxyPrototype.setProperty = function (property, value, a, b, c) {
      return this._target[setProperty](property, value, a, b, c)
    };
    var proxy = join("_", name, "proxy");
    this[getModel] = function () {
      if (this[external]) {
        return this[external]
      }
      if (!this[proxy]) {
        this[proxy] = proxyPrototype.clone();
        this[proxy]._target = this;
        this[proxy].$owner = this.$owner
      }
      return this[proxy]
    };
    _super[setModel] = function (model) {
      this[external] = model;
      if (model && !model.$owner) {
        model.$owner = this
      }
    };
    _super[getModel] = function (a, b, c) {
      if (this[external]) {
        return this[external]
      }
      return this.$owner[getModel](a, b, c)
    };
    this[updateModel] = function () {}
  };
  obj.defineProperty = function (name, defaultValue) {
    if (name.match(_pattern)) {
      var defineProperty = join("define", RegExp.$1, "property");
      if (this[defineProperty]) {
        return this[defineProperty](RegExp.$2, defaultValue)
      }
    }
  };
  obj.definePropertyArray = function (name, defaultValue) {
    if (name.match(_pattern)) {
      var defineArray = join("define", RegExp.$1, "property", "array");
      if (this[defineArray]) {
        return this[defineArray](RegExp.$2, defaultValue)
      }
    }
  }
};
Active.System.Control.create();
Active.Formats.String = Active.System.Format.subclass();
Active.Formats.String.create = function () {
  var obj = this.prototype;
  obj.dataToValue = function (data) {
    return data.toUpperCase()
  };
  obj.dataToText = function (data) {
    return data
  }
};
Active.Formats.String.create();
Active.Formats.Number = Active.System.Format.subclass();
Active.Formats.Number.create = function () {
  var obj = this.prototype;
  obj.dataToValue = function (data) {
    return Number(data)
  };
  var noFormat = function (value) {
      return "" + value
    };
  var doFormat = function (value) {
      var multiplier = this._multiplier;
      var abs = (value < 0) ? -value : value;
      var delta = (value < 0) ? -0.5 : +0.5;
      var rounded = (Math.round(value * multiplier) + delta) / multiplier + "";
      if (abs < 1000) {
        return rounded.replace(this.p1, this.r1)
      }
      if (abs < 1000000) {
        return rounded.replace(this.p2, this.r2)
      }
      if (abs < 1000000000) {
        return rounded.replace(this.p3, this.r3)
      }
      return rounded.replace(this.p4, this.r4)
    };
  obj.setTextFormat = function (format) {
    var pattern = /^([^0#]*)([0#]*)([ .,]?)([0#]|[0#]{3})([.,])([0#]*)([^0#]*)$/;
    var f = format.match(pattern);
    if (!f) {
      this.valueToText = noFormat;
      return
    }
    this.valueToText = doFormat;
    var rs = f[1];
    var rg = f[3];
    var rd = f[5];
    var re = f[7];
    var decimals = f[6].length;
    this._multiplier = Math.pow(10, decimals);
    var ps = "^(-?\\d+)",
      pm = "(\\d{3})",
      pe = "\\.(\\d{" + decimals + "})\\d$";
    this.p1 = new RegExp(ps + pe);
    this.p2 = new RegExp(ps + pm + pe);
    this.p3 = new RegExp(ps + pm + pm + pe);
    this.p4 = new RegExp(ps + pm + pm + pm + pe);
    this.r1 = rs + "$1" + rd + "$2" + re;
    this.r2 = rs + "$1" + rg + "$2" + rd + "$3" + re;
    this.r3 = rs + "$1" + rg + "$2" + rg + "$3" + rd + "$4" + re;
    this.r4 = rs + "$1" + rg + "$2" + rg + "$3" + rg + "$4" + rd + "$5" + re
  };
  obj.setTextFormat("#.##")
};
Active.Formats.Number.create();
Active.Formats.Date = Active.System.Format.subclass();
Active.Formats.Date.create = function () {
  var obj = this.prototype;
  obj.date = new Date();
  obj.digits = [];
  obj.shortMonths = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
  obj.longMonths = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
  obj.shortWeekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
  obj.longWeekdays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
  for (var i = 0; i < 100; i++) {
    obj.digits[i] = i < 10 ? "0" + i : "" + i
  }
  var tokens = {
    "hh": "this.digits[this.date.getUTCHours()]",
    ":mm": "':'+this.digits[this.date.getUTCMinutes()]",
    "mm:": "this.digits[this.date.getUTCMinutes()]+':'",
    "ss": "this.digits[this.date.getUTCSeconds()]",
    "dddd": "this.longWeekdays[this.date.getUTCDay()]",
    "ddd": "this.shortWeekdays[this.date.getUTCDay()]",
    "dd": "this.digits[this.date.getUTCDate()]",
    "d": "this.date.getUTCDate()",
    "mmmm": "this.longMonths[this.date.getUTCMonth()]",
    "mmm": "this.shortMonths[this.date.getUTCMonth()]",
    "mm": "this.digits[this.date.getUTCMonth()+1]",
    "m": "(this.date.getUTCMonth()+1)",
    "yyyy": "this.date.getUTCFullYear()",
    "yy": "this.digits[this.date.getUTCFullYear()%100]"
  };
  var match = "";
  for (i in tokens) {
    if (typeof (i) == "string") {
      match += "|" + i
    }
  }
  var re = new RegExp(match.replace("|", "(") + ")", "gi");
  obj.setTextFormat = function (format) {
    format = format.replace(re, function (i) {
      return "'+" + tokens[i.toLowerCase()] + "+'"
    });
    format = "if(isNaN(value)||(value===this._valueError))return this._textError;" + "this.date.setTime(value+this._textTimezoneOffset);" + ("return '" + format + "'").replace(/(''\+|\+'')/g, "");
    this.valueToText = new Function("value", format)
  };
  var xmlExpr = /^(....).(..).(..).(..).(..).(..)........(...).(..)/;
  var xmlOut = "$1/$2/$3 $4:$5:$6 GMT$7$8";
  var auto = function (data) {
      var value = Date.parse(data + this._dataTimezoneCode);
      return isNaN(value) ? this._valueError : value
    };
  var RFC822 = function (data) {
      var value = Date.parse(data);
      return isNaN(value) ? this._valueError : value
    };
  var ISO8061 = function (data) {
      var value = Date.parse(data.replace(xmlExpr, xmlOut));
      return isNaN(value) ? this._valueError : value
    };
  obj.setDataFormat = function (format) {
    if (format == "RFC822") {
      this.dataToValue = RFC822
    } else if (format == "ISO8061") {
      this.dataToValue = ISO8061
    } else {
      this.dataToValue = auto
    }
  };
  obj.setTextTimezone = function (value) {
    this._textTimezoneOffset = value
  };
  obj.setDataTimezone = function (value) {
    if (!value) {
      this._dataTimezoneCode = " GMT"
    } else {
      this._dataTimezoneCode = " GMT" + (value > 0 ? "+" : "-") + this.digits[Math.floor(Math.abs(value / 3600000))] + this.digits[Math.abs(value / 60000) % 60]
    }
  };
  var localTimezone = -obj.date.getTimezoneOffset() * 60000;
  obj.setTextTimezone(localTimezone);
  obj.setDataTimezone(localTimezone);
  obj.setTextFormat("d mmm yy");
  obj.setDataFormat("default")
};
Active.Formats.Date.create();
Active.HTML.define = function (name, tag, type) {
  if (!tag) {
    tag = name.toLowerCase()
  }
  Active.HTML[name] = Active.System.HTML.subclass();
  Active.HTML[name].create = function () {};
  Active.HTML[name].prototype.setTag(tag)
};
Active.HTML.define("DIV");
Active.HTML.define("SPAN");
Active.HTML.define("IMG");
Active.HTML.define("INPUT");
Active.HTML.define("BUTTON");
Active.HTML.define("TEXTAREA");
Active.HTML.define("TABLE");
Active.HTML.define("TR");
Active.HTML.define("TD");
Active.Templates.Status = Active.System.Template.subclass();
Active.Templates.Status.create = function () {
  var obj = this.prototype;
  obj.setClass("templates", "status");
  var image = new Active.HTML.SPAN;
  image.setClass("box", "image");
  image.setClass("image", function () {
    return this.getStatusProperty("image")
  });
  obj.setContent("image", image);
  obj.setContent("text", function () {
    return this.getStatusProperty("text")
  })
};
Active.Templates.Status.create();
Active.Templates.Error = Active.System.Template.subclass();
Active.Templates.Error.create = function () {
  var obj = this.prototype;
  obj.setClass("templates", "error");
  obj.setContent("title", "Error:");
  obj.setContent("text", function () {
    return this.getErrorProperty("text")
  })
};
Active.Templates.Error.create();
Active.Templates.Text = Active.System.Template.subclass();
Active.Templates.Text.create = function () {
  var obj = this.prototype;
  obj.setClass("templates", "text");
  obj.setContent("text", function () {
    return this.getItemProperty("text")
  });
  obj.setEvent("onclick", function () {
    this.action("click")
  })
};
Active.Templates.Text.create();
Active.Templates.Image = Active.System.Template.subclass();
Active.Templates.Image.create = function () {
  var obj = this.prototype;
  obj.setClass("templates", "image");
  var image = new Active.HTML.SPAN;
  image.setClass("box", "image");
  image.setClass("image", function () {
    return this.getItemProperty("image")
  });
  obj.setContent("image", image);
  obj.setContent("text", function () {
    return this.getItemProperty("text")
  });
  obj.setEvent("onclick", function () {
    this.action("click")
  })
};
Active.Templates.Image.create();
Active.Templates.Link = Active.System.Template.subclass();
Active.Templates.Link.create = function () {
  var obj = this.prototype;
  obj.setTag("a");
  obj.setClass("templates", "link");
  obj.setAttribute("href", function () {
    return this.getItemProperty("link")
  });
  var image = new Active.HTML.SPAN;
  image.setClass("box", "image");
  image.setClass("image", function () {
    return this.getItemProperty("image")
  });
  obj.setContent("image", image);
  obj.setContent("text", function () {
    return this.getItemProperty("text")
  });
  obj.setEvent("onclick", function () {
    this.action("click")
  })
};
Active.Templates.Link.create();
Active.Templates.Item = Active.System.Template.subclass();
Active.Templates.Item.create = function () {
  var obj = this.prototype;
  obj.setClass("templates", "item");
  obj.setClass("box", "normal");
  var box = new Active.HTML.DIV;
  var image = new Active.HTML.SPAN;
  box.setClass("box", "item");
  image.setClass("box", "image");
  image.setClass("image", function () {
    return this.getItemProperty("image")
  });
  obj.setContent("box", box);
  obj.setContent("box/image", image);
  obj.setContent("box/text", function () {
    return this.getItemProperty("text")
  })
};
Active.Templates.Item.create();
Active.Templates.List = Active.System.Template.subclass();
Active.Templates.List.create = function () {
  var obj = this.prototype;
  obj.setTag("");
  obj.defineTemplate("item", new Active.Templates.Text);
  var getItemProperty = function (property) {
      return this.$owner.getDataProperty(property, this.$index)
    };
  var setItemProperty = function (property, value) {
      return this.$owner.setDataProperty(property, value, this.$index)
    };
  obj.getItemTemplate = function (index, temp) {
    var template = this.defaultItemTemplate(index);
    if (!temp) {
      temp = []
    }
    if (!temp.selected) {
      temp.selected = [];
      var i, values = this.getSelectionProperty("values");
      for (i = 0; i < values.length; i++) {
        temp.selected[values[i]] = true
      }
      template.getItemProperty = getItemProperty;
      template.setItemProperty = setItemProperty;
      template.setClass("list", "item")
    }
    if (temp.selected[index]) {
      template = template.clone();
      template.$index = "";
      template.setClass("selection", true);
      template.$index = index
    }
    return template
  };
  var html = function () {
      var i, result = [],
        temp = [],
        items = this.getItemsProperty("values");
      for (i = 0; i < items.length; i++) {
        result[i] = this.getItemTemplate(items[i], temp).toString()
      }
      return result.join("")
    };
  obj.setContent("html", html)
};
Active.Templates.List.create();
Active.Templates.Row = Active.Templates.List.subclass();
Active.Templates.Row.create = function () {
  var obj = this.prototype;
  var _super = this.superclass.prototype;
  obj.setTag("div");
  obj.setClass("templates", "row");
  obj.setClass("grid", "row");
  obj.getDataProperty = function (property, i) {
    return this.$owner.getDataProperty(property, this.$index, i)
  };
  obj.setDataProperty = function (property, value, i) {
    return this.$owner.setDataProperty(property, value, this.$index, i)
  };
  obj.getItemsProperty = function (property) {
    return this.getColumnProperty(property)
  };
  obj.getSelectionProperty = function (property) {
    return this.getDummyProperty(property)
  };
  obj.getRowProperty = function (property) {
    return this.$owner.getItemsProperty(property, this.$index)
  };
  var getItemProperty = function (property) {
      return this.$owner.getDataProperty(property, this.$index)
    };
  var setItemProperty = function (property, value) {
      return this.$owner.setDataProperty(property, value, this.$index)
    };
  var getColumnProperty = function (property) {
      return this.$owner.getColumnProperty(property, this.$index)
    };
  obj.getItemTemplate = function (i) {
    if (!this._itemTemplates) {
      this._itemTemplates = []
    }
    if (this._itemTemplates[i]) {
      this._itemTemplates[i]._id = this._id + ".item:" + i;
      this._itemTemplates[i].$owner = this;
      return this._itemTemplates[i]
    }
    if (typeof (i) == "undefined") {
      return _super.getItemTemplate.call(this)
    }
    var template = _super.getItemTemplate.call(this, i).clone();
    template.$index = i;
    template.setClass("column", i);
    this._itemTemplates[i] = template;
    return template
  };
  obj.setItemTemplate = function (template, i) {
    template.getItemProperty = getItemProperty;
    template.setItemProperty = setItemProperty;
    template.getColumnProperty = getColumnProperty;
    template.setClass("row", "cell");
    template.setClass("grid", "column");
    if (typeof (i) == "undefined") {
      return _super.setItemTemplate.call(this, template)
    }
    template.setClass("column", i);
    template.$owner = this;
    template.$index = i;
    if (!this._itemTemplates) {
      this._itemTemplates = []
    }
    this._itemTemplates[i] = template
  };
  var selectRow = function (event) {
      if (event.shiftKey) {
        return this.action("selectRangeOfRows")
      }
      if (event.ctrlKey) {
        return this.action("selectMultipleRows")
      }
      this.action("selectRow")
    };
  obj.setEvent("onclick", selectRow)
};
Active.Templates.Row.create();
Active.Templates.Header = Active.Templates.Item.subclass();
Active.Templates.Header.create = function () {
  var obj = this.prototype;
  obj.setClass("templates", "header");
  obj.setClass("column", function () {
    return this.$index
  });
  obj.setClass("sort", function () {
    return this.getSortProperty("index") != this.$index ? "none" : this.getSortProperty("direction")
  });
  obj.setAttribute("title", function () {
    return this.getItemProperty("tooltip")
  });
  var div = new Active.HTML.DIV;
  div.setClass("box", "resize");
  div.setEvent("onmousedown", function () {
    this.action("startColumnResize")
  });
  div.setContent("html", "&nbsp;");
  obj.setContent("div", div);
  obj.setEvent("onmousedown", function () {
    this.setClass("header", "pressed");
    window.status = "Sorting...";
    this.timeout(function () {
      this.action("columnSort")
    })
  });
  var sort = new Active.HTML.SPAN;
  sort.setClass("box", "sort");
  obj.setContent("box/sort", sort);
  obj.setEvent("onmouseenter", "mouseover(this,'active-header-over')");
  obj.setEvent("onmouseleave", "mouseout(this,'active-header-over')")
};
Active.Templates.Header.create();
Active.Templates.Box = Active.System.Template.subclass();
Active.Templates.Box.create = function () {
  var obj = this.prototype;
  obj.setClass("templates", "box");
  obj.setClass("box", "normal");
  var box = new Active.HTML.DIV;
  box.setClass("box", "item");
  obj.setContent("box", box)
};
Active.Templates.Box.create();
Active.Templates.Scroll = Active.System.Template.subclass();
Active.Templates.Scroll.create = function () {
  var obj = this.prototype;
  var _super = this.superclass.prototype;
  obj.setTag("");
  var Pane = Active.HTML.DIV;
  var Box = Active.Templates.Box;
  var data = new Pane;
  var top = new Pane;
  var left = new Pane;
  var corner = new Box;
  var fill = new Box;
  var scrollbars = new Pane;
  var space = new Pane;
  data.setClass("scroll", "data");
  top.setClass("scroll", "top");
  left.setClass("scroll", "left");
  corner.setClass("scroll", "corner");
  fill.setClass("scroll", "fill");
  scrollbars.setClass("scroll", "bars");
  space.setClass("scroll", "space");
  obj.setContent("data", data);
  obj.setContent("top", top);
  obj.setContent("left", left);
  obj.setContent("corner", corner);
  obj.setContent("scrollbars", scrollbars);
  obj.setContent("data/html", function () {
    return this.getMainTemplate()
  });
  obj.setContent("top/html", function () {
    return this.getTopTemplate()
  });
  obj.setContent("left/html", function () {
    return this.getLeftTemplate()
  });
  obj.setContent("scrollbars/space", space);
  obj.setContent("top/fill", fill);
  var scroll = function () {
      var scrollbars = this.getContent("scrollbars").element();
      var data = this.getContent("data").element();
      var top = this.getContent("top").element();
      var left = this.getContent("left").element();
      var x = scrollbars.scrollLeft;
      var y = scrollbars.scrollTop;
      data.scrollLeft = x;
      top.scrollLeft = x;
      data.scrollTop = y;
      left.scrollTop = y;
      scrollbars = null;
      data = null;
      top = null;
      left = null
    };
  scrollbars.setEvent("onscroll", scroll);
  var resize = function () {
      if (this._sizeAdjusted) {
        this._sizeAdjusted = false;
        this.timeout(adjustSize, 100);
        var data = this.getContent("data").element();
        var scrollbars = this.getContent("scrollbars").element();
        var top = this.getContent("top").element();
        var left = this.getContent("left").element();
        data.runtimeStyle.width = "100%";
        top.runtimeStyle.width = "100%";
        data.runtimeStyle.height = "100%";
        left.runtimeStyle.height = "100%";
        scrollbars.runtimeStyle.zIndex = 1000;
        data = null;
        scrollbars = null;
        top = null;
        left = null
      }
    };
  scrollbars.setEvent("onresize", resize);
  obj._sizeAdjusted = true;
  var adjustSize = function () {
      var data = this.getContent("data").element();
      var scrollbars = this.getContent("scrollbars").element();
      var top = this.getContent("top").element();
      var left = this.getContent("left").element();
      var space = this.getContent("scrollbars/space").element();
      if (data) {
        if (data.scrollHeight) {
          space.runtimeStyle.height = data.scrollHeight > data.offsetHeight ? data.scrollHeight : 0;
          space.runtimeStyle.width = data.scrollWidth > data.offsetWidth ? data.scrollWidth : 0;
          var y = scrollbars.clientHeight;
          var x = scrollbars.clientWidth;
          data.runtimeStyle.width = x;
          top.runtimeStyle.width = x;
          data.runtimeStyle.height = y;
          left.runtimeStyle.height = y;
          top.scrollLeft = data.scrollLeft;
          left.scrollTop = data.scrollTop;
          scrollbars.runtimeStyle.zIndex = 0
        } else {
          this.timeout(adjustSize, 500)
        }
        data.className = data.className + ""
      }
      data = null;
      scrollbars = null;
      top = null;
      left = null;
      space = null;
      this._sizeAdjusted = true
    };
  obj.setAction("adjustSize", function () {
    this.timeout(adjustSize, 500)
  });
  obj.toString = function () {
    this.timeout(adjustSize);
    return _super.toString.call(this)
  }
};
Active.Templates.Scroll.create();
Active.Controls.Grid = Active.System.Control.subclass();
Active.Controls.Grid.create = function () {
  var obj = this.prototype;
  obj.setClass("controls", "grid");
  obj.setAttribute("tabIndex", "-1");
  obj.setAttribute("hideFocus", "true");
  obj.defineTemplate("layout", new Active.Templates.Scroll);
  obj.defineTemplate("main", function () {
    switch (this.getStatusProperty("code")) {
    case "":
      return this.getDataTemplate();
    case "error":
      return this.getErrorTemplate();
    default:
      return this.getStatusTemplate()
    }
  });
  obj.defineTemplate("data", new Active.Templates.List);
  obj.defineTemplate("left", new Active.Templates.List);
  obj.defineTemplate("top", new Active.Templates.List);
  obj.defineTemplate("status", new Active.Templates.Status);
  obj.defineTemplate("error", new Active.Templates.Error);
  obj.defineTemplate("row", new Active.System.Template);
  obj.defineTemplate("column", new Active.System.Template);
  obj.getColumnTemplate = function (i) {
    return this.getTemplate("data/item/item", i)
  };
  obj.setColumnTemplate = function (template, i) {
    this.setTemplate("data/item/item", template, i)
  };
  obj.getRowTemplate = function (i) {
    return this.getTemplate("data/item", i)
  };
  obj.setRowTemplate = function (template, i) {
    this.setTemplate("data/item", template, i)
  };
  obj.setTemplate("data/item", new Active.Templates.Row);
  obj.setTemplate("left/item", new Active.Templates.Item);
  obj.setTemplate("top/item", new Active.Templates.Header);
  obj.defineModel("row");
  obj.defineRowProperty("count", function () {
    return this.getDataProperty("count")
  });
  obj.defineRowProperty("index", function (i) {
    return i
  });
  obj.defineRowProperty("order", function (i) {
    return i
  });
  obj.defineRowPropertyArray("text", function (i) {
    return this.getRowOrder(i) + 1
  });
  obj.defineRowPropertyArray("image", "none");
  obj.defineRowPropertyArray("value", function (i) {
    return i
  });
  obj.defineModel("column");
  obj.defineColumnProperty("count", 0);
  obj.defineColumnProperty("index", function (i) {
    return i
  });
  obj.defineColumnProperty("order", function (i) {
    return i
  });
  obj.defineColumnPropertyArray("text", function (i) {
    return "Column " + i
  });
  obj.defineColumnPropertyArray("image", "none");
  obj.defineColumnPropertyArray("value", function (i) {
    return i
  });
  obj.defineColumnPropertyArray("tooltip", "");
  obj.defineModel("data");
  obj.defineDataProperty("count", 0);
  obj.defineDataProperty("index", function (i) {
    return i
  });
  obj.defineDataProperty("text", "");
  obj.defineDataProperty("image", "none");
  obj.defineDataProperty("link", "");
  obj.defineDataProperty("value", function (i, j) {
    var text = "" + this.getDataText(i, j);
    var value = Number(text.replace(/[,%\$]/gi, "").replace(/\((.*)\)/, "-$1"));
    return isNaN(value) ? text.toLowerCase() + " " : value
  });
  obj.defineModel("items");
  obj.defineModel("dummy");
  obj.defineDummyProperty("count", 0);
  obj.defineDummyPropertyArray("value", -1);
  obj.defineModel("selection");
  obj.defineSelectionProperty("index", -1);
  obj.defineSelectionProperty("multiple", false);
  obj.defineSelectionProperty("count", 0);
  obj.defineSelectionPropertyArray("value", 0);
  obj.defineModel("sort");
  obj.defineSortProperty("index", -1);
  obj.defineSortProperty("direction", "none");
  obj.defineModel("status");
  obj.defineStatusProperty("code", function () {
    var data = this.getDataModel();
    if (!data.isReady()) {
      return "loading"
    }
    if (!this.getRowProperty("count")) {
      return "nodata"
    }
    return ""
  });
  obj.defineStatusProperty("text", function () {
    switch (this.getStatusProperty("code")) {
    case "loading":
      return "Loading data,please wait...";
    case "nodata":
      return "No data found.";
    default:
      return ""
    }
  });
  obj.defineStatusProperty("image", function () {
    switch (this.getStatusProperty("code")) {
    case "loading":
      return "loading";
    default:
      return "none"
    }
  });
  obj.defineModel("error");
  obj.defineErrorProperty("code", 0);
  obj.defineErrorProperty("text", "");
  obj.getLeftTemplate = function () {
    var template = this.defaultLeftTemplate();
    template.setDataModel(this.getRowModel());
    template.setItemsModel(this.getRowModel());
    template.setSelectionModel(this.getDummyModel());
    return template
  };
  obj.getTopTemplate = function () {
    var template = this.defaultTopTemplate();
    template.setDataModel(this.getColumnModel());
    template.setItemsModel(this.getColumnModel());
    template.setSelectionModel(this.getDummyModel());
    return template
  };
  obj.getDataTemplate = function () {
    var template = this.defaultDataTemplate();
    template.setDataModel(this.getDataModel());
    template.setItemsModel(this.getRowModel());
    return template
  };
  obj.setContent(function () {
    return this.getLayoutTemplate()
  });
  obj.setColumnHeaderHeight = function (height) {
    var layout = this.getTemplate("layout");
    layout.getContent("top").setStyle("height", height);
    layout.getContent("corner").setStyle("height", height);
    layout.getContent("left").setStyle("padding-top", height);
    layout.getContent("data").setStyle("padding-top", height)
  };
  obj.setRowHeaderWidth = function (width) {
    var layout = this.getTemplate("layout");
    layout.getContent("left").setStyle("width", width);
    layout.getContent("corner").setStyle("width", width);
    layout.getContent("top").setStyle("padding-left", width);
    layout.getContent("data").setStyle("padding-left", width)
  };
  var startColumnResize = function (header) {
      var el = header.element();
      var pos = event.clientX;
      var size = el.offsetWidth;
      var grid = this;
      var doResize = function () {
          var el = header.element();
          var sz = size + event.clientX - pos;
          el.style.width = sz < 10 ? 10 : sz;
          el = null
        };
      var endResize = function () {
          var el = header.element();
          if (typeof el.onmouseleave == "function") {
            el.onmouseleave()
          }
          el.detachEvent("onmousemove", doResize);
          el.detachEvent("onmouseup", endResize);
          el.detachEvent("onlosecapture", endResize);
          el.releaseCapture();
          var width = size + event.clientX - pos;
          if (width < 10) {
            width = 10
          }
          el.style.width = width;
          var ss = document.styleSheets[document.styleSheets.length - 1];
          var i, selector = "#" + grid.getId() + " .active-column-" + header.getItemProperty("index");
          for (i = 0; i < ss.rules.length; i++) {
            if (ss.rules[i].selectorText == selector) {
              ss.rules[i].style.width = width;
              el = null;
              grid.getTemplate("layout").action("adjustSize");
              return
            }
          }
          ss.addRule(selector, "width:" + width + "px");
          el = null;
          grid.getTemplate("layout").action("adjustSize")
        };
      el.attachEvent("onmousemove", doResize);
      el.attachEvent("onmouseup", endResize);
      el.attachEvent("onlosecapture", endResize);
      el.setCapture();
      el = null;
      event.cancelBubble = true
    };
  obj.setAction("startColumnResize", startColumnResize);
  var setSelectionIndex = obj.setSelectionIndex;
  obj.setSelectionIndex = function (index) {
    setSelectionIndex.call(this, index);
    this.setSelectionValues([index]);
    var row = this.getTemplate("row", index);
    var data = this.getTemplate("layout").getContent("data");
    var left = this.getTemplate("layout").getContent("left");
    var scrollbars = this.getTemplate("layout").getContent("scrollbars");
    try {
      var top, padding = data.element().firstChild.offsetTop;
      if (data.element().scrollTop > row.element().offsetTop - padding) {
        top = row.element().offsetTop - padding;
        left.element().scrollTop = top;
        data.element().scrollTop = top;
        scrollbars.element().scrollTop = top
      }
      if (data.element().offsetHeight + data.element().scrollTop < row.element().offsetTop + row.element().offsetHeight) {
        top = row.element().offsetTop + row.element().offsetHeight - data.element().offsetHeight;
        left.element().scrollTop = top;
        data.element().scrollTop = top;
        scrollbars.element().scrollTop = top
      }
    } catch (error) {}
  };
  var setSelectionValues = obj.setSelectionValues;
  obj.setSelectionValues = function (array) {
    var i, current = this.getSelectionValues();
    setSelectionValues.call(this, array);
    var changes = {};
    for (i = 0; i < current.length; i++) {
      changes[current[i]] = true
    }
    for (i = 0; i < array.length; i++) {
      changes[array[i]] = changes[array[i]] ? false : true
    }
    for (i in changes) {
      if (changes[i] === true) {
        this.getRowTemplate(i).refreshClasses()
      }
    }
    this.action("selectionChanged")
  };
  var selectRow = function (src) {
      this.setSelectionProperty("index", src.getItemProperty("index"))
    };
  var selectMultipleRows = function (src) {
      if (!this.getSelectionProperty("multiple")) {
        return this.action("selectRow", src)
      }
      var index = src.getItemProperty("index");
      var selection = this.getSelectionProperty("values");
      for (var i = 0; i < selection.length; i++) {
        if (selection[i] == index) {
          selection.splice(i, 1);
          i = -1;
          break
        }
      }
      if (i != -1) {
        selection.push(index)
      }
      this.setSelectionProperty("values", selection);
      setSelectionIndex.call(this, index);
      this.getRowTemplate(index).refreshClasses();
      this.action("selectionChanged")
    };
  var selectRangeOfRows = function (src) {
      if (!this.getSelectionProperty("multiple")) {
        return this.action("selectRow", src)
      }
      var previous = this.getSelectionProperty("index");
      var index = src.getItemProperty("index");
      var row1 = Number(this.getRowProperty("order", previous));
      var row2 = Number(this.getRowProperty("order", index));
      var start = row1 > row2 ? row2 : row1;
      var count = row1 > row2 ? row1 - row2 : row2 - row1;
      var i, selection = [];
      for (i = 0; i <= count; i++) {
        selection.push(this.getRowProperty("value", start + i))
      }
      this.setSelectionProperty("values", selection);
      setSelectionIndex.call(this, index);
      this.getRowTemplate(index).refreshClasses();
      this.action("selectionChanged")
    };
  obj.setAction("selectRow", selectRow);
  obj.setAction("selectMultipleRows", selectMultipleRows);
  obj.setAction("selectRangeOfRows", selectRangeOfRows);
  obj.sort = function (index, direction) {
    var model = this.getModel("row");
    if (model.sort) {
      return model.sort(index, direction)
    }
    function compare(value, pos, dir) {
      var greater = 1,
        less = -1;
      if (dir == "descending") {
        greater = -1;
        less = 1
      }
      var types = {
        "undefined": 0,
        "boolean": 1,
        "number": 2,
        "string": 3,
        "object": 4,
        "function": 5
      };
      return function (i, j) {
        var a = value[i],
          b = value[j],
          x, y;
        if (typeof (a) != typeof (b)) {
          x = types[typeof (a)];
          y = types[typeof (b)];
          if (x > y) {
            return greater
          }
          if (x < y) {
            return less
          }
        } else if (typeof (a) == "number") {
          if (a > b) {
            return greater
          }
          if (a < b) {
            return less
          }
        } else {
          var result = ("" + a).localeCompare(b);
          if (result) {
            return greater * result
          }
        }
        x = pos[i];
        y = pos[j];
        if (x > y) {
          return 1
        }
        if (x < y) {
          return -1
        }
        return 0
      }
    }
    if (direction && direction != "ascending") {
      direction = "descending"
    } else {
      direction = "ascending"
    }
    var i, value = {},
      pos = {};
    var rows = this.getRowProperty("values");
    for (i = 0; i < rows.length; i++) {
      value[rows[i]] = this.getDataProperty("value", rows[i], index);
      pos[rows[i]] = i
    }
    rows.sort(compare(value, pos, direction));
    this.setRowProperty("values", rows);
    this.setSortProperty("index", index);
    this.setSortProperty("direction", direction)
  };
  obj.setAction("columnSort", function (src) {
    var i = src.getItemProperty("index");
    var d = (this.getSortProperty("index") == i) && (this.getSortProperty("direction") == "ascending") ? "descending" : "ascending";
    window.status = "Sorting...";
    this.sort(i, d);
    this.refresh();
    this.timeout(function () {
      window.status = ""
    })
  });
  var _getRowOrder = function (i) {
      return this._rowOrders[i]
    };
  var _setRowValues = obj.setRowValues;
  obj.setRowValues = function (values) {
    _setRowValues.call(this, values);
    var i, max = values.length,
      orders = [];
    for (i = 0; i < max; i++) {
      orders[values[i]] = i
    }
    this._rowOrders = orders;
    this.getRowOrder = _getRowOrder
  };
  obj._kbSelect = function (delta) {
    var index = this.getSelectionProperty("index");
    var order = this.getRowProperty("order", index);
    var count = this.getRowProperty("count");
    var newOrder = Number(order) + delta;
    if (newOrder < 0) {
      newOrder = 0
    }
    if (newOrder > count - 1) {
      newOrder = count - 1
    }
    if (delta == -100) {
      newOrder = 0
    }
    if (delta == 100) {
      newOrder = count - 1
    }
    var newIndex = this.getRowProperty("value", newOrder);
    this.setSelectionProperty("index", newIndex)
  };
  obj.setAction("up", function () {
    this._kbSelect(-1)
  });
  obj.setAction("down", function () {
    this._kbSelect(+1)
  });
  obj.setAction("pageUp", function () {
    this._kbSelect(-10)
  });
  obj.setAction("pageDown", function () {
    this._kbSelect(+10)
  });
  obj.setAction("home", function () {
    this._kbSelect(-100)
  });
  obj.setAction("end", function () {
    this._kbSelect(+100)
  });
  var kbActions = {
    38: "up",
    40: "down",
    33: "pageUp",
    34: "pageDown",
    36: "home",
    35: "end"
  };
  var onkeydown = function (event) {
      var action = kbActions[event.keyCode];
      if (action) {
        this.action(action);
        event.returnValue = false;
        event.cancelBubble = true
      }
    };
  obj.setEvent("onkeydown", onkeydown);

  function onmousewheel(event) {
    var scrollbars = this.getTemplate("layout").getContent("scrollbars");
    var delta = scrollbars.element().offsetHeight * event.wheelDelta / 480;
    scrollbars.element().scrollTop -= delta;
    event.returnValue = false;
    event.cancelBubble = true
  }
  obj.setEvent("onmousewheel", onmousewheel)
};
Active.Controls.Grid.create();
Active.HTTP.Request = Active.System.Model.subclass();
Active.HTTP.Request.create = function () {
  var obj = this.prototype;
  obj.defineProperty("URL");
  obj.defineProperty("async", true);
  obj.defineProperty("requestMethod", "GET");
  obj.defineProperty("requestData", "");
  obj.defineProperty("responseText", function () {
    return this._http ? this._http.responseText : ""
  });
  obj.defineProperty("responseXML", function () {
    return this._http ? this._http.responseXML : ""
  });
  obj.defineProperty("username", null);
  obj.defineProperty("password", null);
  obj.setNamespace = function (name, value) {
    this._namespaces += " xmlns:" + name + "=\"" + value + "\""
  };
  obj._namespaces = "";
  obj.setParameter = function (name, value) {
    this["_" + name + "Parameter"] = value;
    if ((this._parameters + " ").indexOf(" " + name + " ") < 0) {
      this._parameters += " " + name
    }
  };
  obj._parameters = "";
  obj.setRequestHeader = function (name, value) {
    this["_" + name + "Header"] = value;
    if ((this._headers + " ").indexOf(" " + name + " ") < 0) {
      this._headers += " " + name
    }
  };
  obj._headers = "";
  obj.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
  obj.getResponseHeader = function (name) {
    return this._http ? this._http.getResponseHeader(name) : ""
  };
  obj.request = function () {
    var self = this;
    this._ready = false;
    var i, name, value, data = "",
      params = this._parameters.split(" ");
    for (i = 1; i < params.length; i++) {
      name = params[i];
      value = this["_" + name + "Parameter"];
      if (typeof value == "function") {
        value = value()
      }
      data += name + "=" + encodeURIComponent(value) + "&"
    }
    var URL = this._URL;
    if ((this._requestMethod != "POST") && data) {
      URL += "?" + data;
      data = null
    }
    this._http = window.ActiveXObject ? new ActiveXObject("MSXML2.XMLHTTP") : new XMLHttpRequest;
    this._http.open(this._requestMethod, URL, this._async, this._username, this._password);
    var headers = this._headers.split(" ");
    for (i = 1; i < headers.length; i++) {
      name = headers[i];
      value = this["_" + name + "Header"];
      if (typeof value == "function") {
        value = value()
      }
      this._http.setRequestHeader(name, value)
    }
    this._http.send(data);
    if (this._async) {
      this.timeout(wait, 200)
    } else {
      returnResult()
    }
    function wait() {
      if (self._http.readyState == 4) {
        self._ready = true;
        returnResult()
      } else {
        self.timeout(wait, 200)
      }
    }
    function returnResult() {
      if (self._http.responseXML && self._http.responseXML.hasChildNodes()) {
        self.response(self._http.responseXML)
      } else {
        self.response(self._http.responseText)
      }
    }
  };
  obj.response = function (result) {
    if (this.$owner) {
      this.$owner.refresh()
    }
  };
  obj.isReady = function () {
    return this._ready
  }
};
Active.HTTP.Request.create();
Active.Text.Table = Active.HTTP.Request.subclass();
Active.Text.Table.create = function () {
  var obj = this.prototype;
  var _super = this.superclass.prototype;
  obj.response = function (text) {
    var i, s, table = [],
      a = text.split(/\r*\n/);
    var pattern = new RegExp("(^|\\t|,)(\"*|'*)(.*?)\\2(?=,|\\t|$)", "g");
    for (i = 0; i < a.length; i++) {
      s = a[i].replace(/""/g, "'");
      s = s.replace(pattern, "$3\t");
      s = s.replace(/\t$/, "");
      if (s) {
        table[i] = s.split(/\t/)
      }
    }
    this._data = table;
    _super.response.call(this)
  };
  obj._data = [];
  obj.getCount = function () {
    return this._data.length
  };
  obj.getIndex = function (i) {
    return i
  };
  obj.getText = function (i, j) {
    return this._data[i][j]
  };
  obj.getImage = function () {
    return "none"
  };
  obj.getLink = function () {
    return ""
  };
  obj.getValue = function (i, j) {
    var text = this.getText(i, j);
    var value = Number(text.replace(/[,%\$]/gi, "").replace(/\((.*)\)/, "-$1"));
    return isNaN(value) ? text.toLowerCase() + " " : value
  }
};
Active.Text.Table.create();
Active.XML.Table = Active.HTTP.Request.subclass();
Active.XML.Table.create = function () {
  var obj = this.prototype;
  var _super = this.superclass.prototype;
  obj.response = function (xml) {
    this.setXML(xml);
    _super.response.call(this)
  };
  obj.defineProperty("XML");
  obj.setXML = function (xml) {
    if (!xml.nodeType) {
      var s = "" + xml;
      if (window.ActiveXObject) {
        xml = new ActiveXObject("MSXML2.DOMDocument");
        xml.loadXML(s);
        xml.setProperty("SelectionLanguage", "XPath")
      } else {
        xml = (new DOMParser).parseFromString(s, "text/xml")
      }
    }
    if (this._namespaces) {
      xml.setProperty("SelectionNamespaces", this._namespaces)
    }
    this._xml = xml;
    this._data = this._xml.selectSingleNode(this._dataPath);
    this._items = this._data ? this._data.selectNodes(this._itemPath) : null;
    this._ready = true
  };
  obj.getXML = function () {
    return this._xml
  };
  obj._dataPath = "*";
  obj._itemPath = "*";
  obj._valuePath = "*";
  obj._valuesPath = [];
  obj._formats = [];
  obj.setColumns = function (array) {
    this._valuesPath = array
  };
  obj.setRows = function (xpath) {
    this._itemPath = xpath
  };
  obj.setTable = function (xpath) {
    this._dataPath = xpath
  };
  obj.setFormat = function (format, index) {
    this._formats = this._formats.concat();
    this._formats[index] = format
  };
  obj.setFormats = function (formats) {
    this._formats = formats
  };
  obj.getCount = function () {
    if (!this._items) {
      return 0
    }
    return this._items.length
  };
  obj.getIndex = function (i) {
    return i
  };
  obj.getText = function (i, j) {
    var node = this.getNode(i, j);
    var data = node ? node.text : "";
    var format = this._formats[j];
    return format ? format.dataToText(data) : data
  };
  obj.getImage = function () {
    return "none"
  };
  obj.getLink = function () {
    return ""
  };
  obj.getValue = function (i, j) {
    var node = this.getNode(i, j);
    var text = node ? node.text : "";
    var format = this._formats[j];
    if (format) {
      return format.dataToValue(text)
    }
    var value = Number(text.replace(/[,%\$]/gi, "").replace(/\((.*)\)/, "-$1"));
    return isNaN(value) ? text.toLowerCase() + " " : value
  };
  obj.getNode = function (i, j) {
    if (!this._items || !this._items[i]) {
      return null
    }
    if (this._valuesPath[j]) {
      return this._items[i].selectSingleNode(this._valuesPath[j])
    } else {
      return this._items[i].selectNodes(this._valuePath)[j]
    }
  };
  obj.getData = function (i, j) {
    if (!this._items) {
      return null
    }
    var node = null;
    if (this._valuesPath[j]) {
      node = this._items[i].selectSingleNode(this._valuesPath[j])
    } else {
      node = this._items[i].selectNodes(this._valuePath)[j]
    }
    return node ? node.text : null
  }
};
Active.XML.Table.create();