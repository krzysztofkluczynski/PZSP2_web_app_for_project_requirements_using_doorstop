% rebase('base.tpl', title='Doorstop')
<H1>Doorstop - List of items in {{prefix}}</H1>
<P>
<ul>

%for i in items:
    <li><a href="items/{{i}}">{{i}}</a> <form action="/documents/{{prefix}}/items" method=POST> <input type ="submit" name="Delete" value="Delete"> <input type ="hidden" name="item" value="{{i}}"> </form> </li>
%end

</ul>
</code>
