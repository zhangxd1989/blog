{% if page.comments %}
<script>
  var cloudTieConfig = {
    url: document.location.href, 
    sourceId: "{{ page.path }}",
    productKey: "d281d1d3f59b47b58e58309da9098ab4",
    target: "cloud-tie-wrapper"
  };
</script>
<script src="https://img1.cache.netease.com/f2e/tie/yun/sdk/loader.js"></script>
{% endif %}