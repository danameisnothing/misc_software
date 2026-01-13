Based from the work of GitHub user https://github.com/ading2210's https://github.com/ading2210/sheepy-web-port work
* `index.html` :
Add these in-between the `<noscript>` tag, and the `supportcheck.js` `<script>` tag. Note that the tag order IS important here! Do not swap them.
```html
<script src="https://cdn.jsdelivr.net/npm/gl-matrix@3.4.4/gl-matrix-min.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/requirejs@2.3.8/require.min.js"></script>
```
Example :
```html
<noscript>
    <div id="notSupportedWrap">
        <h2 id="notSupportedTitle">This content requires JavaScript</h2>
        <p class="notSupportedMessage">JavaScript appears to be disabled. Please enable it to view this content.</p>
    </div>
</noscript>
<script src="https://cdn.jsdelivr.net/npm/gl-matrix@3.4.4/gl-matrix-min.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/requirejs@2.3.8/require.min.js"></script>
<script src="scripts/supportcheck.js"></script>
<script src="scripts/main.js" type="module"></script>
```

* `c3runtime.js` :
Change something along the lines of this :
```javascript
this._isNWjs=
this._runtime.GetExportType()==="nwjs"||this._runtime.IsPreview()&&/nwjs\//i.test(navigator.userAgent);
```
Into this :
```javascript
this._isNWjs=false;
```