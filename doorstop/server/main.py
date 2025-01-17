#!/usr/bin/env python
# SPDX-License-Identifier: LGPL-3.0-only
# pylint: disable=import-outside-toplevel

"""REST server to display content and reserve item numbers."""

import argparse
import logging
import os
import webbrowser
from collections import defaultdict
from typing import Dict
import json

import bottle
from bottle import get, hook, post, request, response, template, redirect

from doorstop import Tree, build, common, publisher, settings
from doorstop.common import HelpFormatter
from doorstop.core import vcs
from doorstop.server import utilities

log = common.logger(__name__)

app = utilities.StripPathMiddleware(bottle.app())
tree: Tree = None  # type: ignore
numbers: Dict[str, int] = defaultdict(int)  # cache of next document numbers
repository = None


def main(args=None):
    """Process command-line arguments and run the program."""
    from doorstop import SERVER, VERSION

    # Shared options
    debug = argparse.ArgumentParser(add_help=False)
    debug.add_argument("-V", "--version", action="version", version=VERSION)
    debug.add_argument(
        "--debug", action="store_true", help="run the server in debug mode"
    )
    debug.add_argument(
        "--launch", action="store_true", help="open the server UI in a browser"
    )
    shared = {"formatter_class": HelpFormatter, "parents": [debug]}

    # Build main parser
    parser = argparse.ArgumentParser(prog=SERVER, description=__doc__, **shared)  # type: ignore
    cwd = os.getcwd()

    parser.add_argument(
        "-j", "--project", default=None, help="path to the root of the project"
    )
    parser.add_argument(
        "-P",
        "--port",
        metavar="NUM",
        type=int,
        default=settings.SERVER_PORT,
        help="use a custom port for the server",
    )
    parser.add_argument(
        "-H", "--host", default="127.0.0.1", help="IP address to listen"
    )
    parser.add_argument(
        "-w", "--wsgi", action="store_true", help="Run as a WSGI process"
    )
    parser.add_argument(
        "-b",
        "--baseurl",
        default="",
        help="Base URL this is served at (Usually only necessary for WSGI)",
    )
    parser.add_argument(
        "-G", "--git", default=None, help="Git repository reference for the manager in the author/repo format"
    )

    # Parse arguments
    args = parser.parse_args(args=args)

    if args.project is None:
        args.project = vcs.find_root(cwd)

    # Configure logging
    logging.basicConfig(
        format=settings.VERBOSE_LOGGING_FORMAT, level=settings.VERBOSE_LOGGING_LEVEL
    )

    # Run the program
    run(args, os.getcwd(), parser.error)


def run(args, cwd, _):
    """Start the server.

    :param args: Namespace of CLI arguments (from this module or the CLI)
    :param cwd: current working directory
    :param error: function to call for CLI errors

    """
    global tree
    tree = build(cwd=cwd, root=args.project)
    tree.load()
    host = args.host
    port = args.port or settings.SERVER_PORT
    bottle.TEMPLATE_PATH.insert(
        0, os.path.join(os.path.dirname(__file__), "..", "views")
    )

    # If you started without WSGI, the base will be '/'.
    if args.baseurl == "" and not args.wsgi:
        args.baseurl = "/"

    # If you specified a base URL, make sure it ends with '/'.
    if args.baseurl != "" and not args.baseurl.endswith("/"):
        args.baseurl += "/"

    global repository
    repository = args.git

    bottle.SimpleTemplate.defaults["baseurl"] = args.baseurl
    bottle.SimpleTemplate.defaults["navigation"] = True

    if args.launch:
        url = utilities.build_url(host=host, port=port)
        webbrowser.open(url)
    if not args.wsgi:
        bottle.run(app=app, host=host, port=port, debug=args.debug, reloader=args.debug)


@hook("before_request")
def strip_path():
    request.environ["PATH_INFO"] = request.environ["PATH_INFO"].rstrip("/")
    if (
        len(request.environ["PATH_INFO"]) > 0
        and request.environ["PATH_INFO"][-5:-1] == ".html"
    ):
        request.environ["PATH_INFO"] = request.environ["PATH_INFO"][:-5]


@hook("after_request")
def enable_cors():
    """Allow a webserver running on the same machine to access data."""
    response.headers["Access-Control-Allow-Origin"] = "*"


@get("/")
def index():
    """Read the tree."""
    global repository
    if not tree.document:
        tree.add_document("REQ")
    yield template("index", tree_code=tree.draw(html_links=True), repository=repository)


@post("/")
def post_document_tree():
    """Remove or add documents"""
    post_req = request.json
    document_name = post_req.get("name")
    parent_name = post_req.get("parent")
    print(f"Add document {document_name} with parent {parent_name}")
    parent_document = tree.find_document(parent_name)
    tree.add_document(document_name, parent=parent_document.prefix)
    yield template("index", tree_code=tree.draw(html_links=True), repository=repository)


@get("/documents")
def get_documents():
    """Read the tree's documents."""
    prefixes = [str(document.prefix) for document in tree]
    if utilities.json_response(request):
        data = {"prefixes": prefixes}
        return data
    else:
        return template("document_list", prefixes=prefixes, repository=repository)


@get("/documents/all")
def get_all_documents():
    """Read the tree's documents."""
    if utilities.json_response(request):
        data = {str(d.prefix): {str(i.uid): i.data for i in d} for d in tree}
        return data
    else:
        prefixes = [str(document.prefix) for document in tree]
        return template("document_list", prefixes=prefixes, repository=repository)


@get("/documents/<prefix>")
def get_document(prefix):
    """Read a tree's document."""
    if (len(prefix) > 5 and prefix[-5:] == ".html"):
        prefix = prefix[:-5]
    document = tree.find_document(prefix)
    if utilities.json_response(request):
        data = {str(item.uid): item.data for item in document}
        return data
    else:
        return publisher.publish_lines(document, ext=".html", linkify=True, repository=repository)


@post("/documents/<prefix>")
def post_document(prefix):
    """Modify items in the document"""
    post_req = request.POST
    item_uid = post_req.get("item")
    if "Delete" in post_req:
        tree.remove_item(item_uid)
    elif "Show" in post_req:
        tree.set_item_active(item_uid, True)
    elif "Hide" in post_req:
        tree.set_item_active(item_uid, False)
    elif "Add" in post_req or "Edit" in post_req:
        if "Add" in post_req:
            item = tree.find_item(item_uid)
            level = item.level + 1
            document = tree.find_document(item.document.prefix)
            new_item = document.add_item(level=level)
            item_uid = new_item.uid
        return redirect(f"/documents/{prefix}/items/{item_uid}/edit")
    document = tree.find_document(prefix)
    return publisher.publish_lines(document, ext=".html", linkify=True, repository=repository)


@get("/documents/<prefix>/items")
def get_items(prefix):
    """Read a document's items."""
    document = tree.find_document(prefix)
    uids = [str(item.uid) for item in document]
    if utilities.json_response(request):
        data = {"uids": uids}
        return data
    else:
        return template("item_list", prefix=prefix, items=uids, repository=repository)


@post("/documents/<prefix>/items")
def items_post(prefix):
    delete = request.POST.get('Delete')
    if delete is not None:
        item = request.POST.get('item')
        tree.remove_item(item)

    document = tree.find_document(prefix)
    uids = [str(item.uid) for item in document]
    return template("item_list", prefix=prefix, items=uids, repository=repository)


@get("/documents/<prefix>/items/<uid>")
def get_item(prefix, uid):
    """Read a document's item."""
    document = tree.find_document(prefix)
    item = document.find_item(uid)
    if utilities.json_response(request):
        return {"data": item.data}
    else:
        return publisher.publish_lines(item, ext=".html", repository=repository)


@get("/documents/<prefix>/items/<uid>/attrs")
def get_attrs(prefix, uid):
    """Read an item's attributes."""
    document = tree.find_document(prefix)
    item = document.find_item(uid)
    attrs = sorted(item.data.keys())
    if utilities.json_response(request):
        data = {"attrs": attrs}
        return data
    else:
        return "<br>".join(attrs)


@get("/documents/<prefix>/items/<uid>/attrs/<name>")
def get_attr(prefix, uid, name):
    """Read an item's attribute value."""
    document = tree.find_document(prefix)
    item = document.find_item(uid)
    value = item.data.get(name, None)
    if utilities.json_response(request):
        data = {"value": value}
        return data
    else:
        if isinstance(value, str):
            return value
        try:
            return "<br>".join(str(e) for e in value)
        except TypeError:
            return str(value)


@get("/assets/doorstop/<filename>")
def get_assets(filename):
    """Serve static files. Mainly used to serve CSS files and javascript."""
    public_dir = os.path.join(
        os.path.dirname(__file__), "..", "core", "files", "templates", "html", "doorstop"
    )
    return bottle.static_file(filename, root=public_dir)


@post("/documents/<prefix>/numbers")
def post_numbers(prefix):
    """Create the next number in a document."""
    document = tree.find_document(prefix)
    number = max(document.next_number, numbers[prefix])
    numbers[prefix] = number + 1
    if utilities.json_response(request):
        data = {"next": number}
        return data
    else:
        return str(number)


@get("/documents/<prefix>/items/<uid>/edit")
def edit_item(prefix, uid):
    """Edit item in a document."""    
    document = tree.find_document(prefix)
    item = document.find_item(uid)
    properties = get_item_properties(item)
    updated_properties = update_parent_links(properties)
    return template("editor.tpl", prefix=prefix, uid=uid, properties=updated_properties)

@post("/documents/<prefix>/items/<uid>/edit")
def post_edit(prefix, uid):
    """Handle posts on an item edit site."""
    document = tree.find_document(prefix)
    item = document.find_item(uid)

    post_req = request.json
    action = post_req.get("action")

    if (action == "modify-text"):
        item.text = post_req.get("content")
    elif (action == "modify-level"):
        item.level = post_req.get("content")
    elif (action == "modify-header"):
        item.header = post_req.get("content")
    elif (action == "delete-link"):
        link_type = post_req.get("type")
        link_uid = post_req.get("uid")
        if (link_type == "child"):
            children = item.find_child_items()
            for child in children:
                if (str(child) == str(link_uid)):
                    child.unlink(uid)
        elif (link_type == "parent"):
            item.unlink(link_uid)
        return json.dumps({"success": True})
    elif (action == "add-link"):
        link_type = post_req.get("type")
        link_uid = post_req.get("uid")
        if (link_type == "child"):
            try:
                child_document = tree.find_document(link_uid[:3])
                child_item = child_document.find_item(link_uid)
                child_item.link(uid)
                return json.dumps({"success": True})
            except:
                return json.dumps({"success": False})
        elif (link_type == "parent"):
            try:
                parent_document = tree.find_document(link_uid[:3])
                parent_document.find_item(link_uid)
                item.link(link_uid)
                return json.dumps({"success": True})
            except:
                return json.dumps({"success": False})
    else:
        state = post_req.get("state")

        match action:
            case "active":
                item.active = state
            case "derived":
                item.derived = state
            case "normative":
                item.normative = state
            case "heading":
                item.heading = state

    return redirect(f"/documents/{prefix}/items/{uid}/edit")

def update_parent_links(properties):
    parents = properties["parent-links"]
    parents_info = []
    for parent in parents:
        parent_item = tree.find_item(parent)
        parents_info.append((parent_item, str(parent_item.level) + " " + parent_item.header))
    properties["parent-links"] = parents_info
    return properties

def get_item_properties(item):
    child_items = item.find_child_items()
    child_links = []
    for child in child_items:
        child_links.append((child, str(child.level) + " " + child.header))

    path, line = item.find_ref()

    properties = {
        "active": item.active,
        "derived": item.derived,
        "normative": item.normative,
        "heading": item.heading,
        "header": item.header,
        "level": item.level,
        "parent-links": item.links,
        "child-links": child_links,
        "ref": (path, line),
        "text": item.text
    }
    return properties

if __name__ == "__main__":
    main()
