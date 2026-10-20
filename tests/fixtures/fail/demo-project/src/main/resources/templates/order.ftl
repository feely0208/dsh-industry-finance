<#-- 收银台订单确认页（FreeMarker） -->
<div class="order-card">
  <p>卡号：${cardNo}</p>
  <p>金额：${amount?string("0.00")}</p>
  <p>商户：${merchantName}</p>
</div>
