#!/bin/bash
echo "=== ПРОВЕРКА КОРПОРАТИВНОЙ СЕТИ COMPANY.LOCAL ==="
echo -n "1. Проверка связи со шлюзом (192.168.10.1): "
ping -c 1 192.168.10.1 > /dev/null && echo "OK" || echo "FAIL"

echo -n "2. Проверка локального DNS (app.company.local): "
getent hosts app.company.local > /dev/null && echo "OK" || echo "FAIL"

echo -n "3. HTTP-запрос к Python Backend: "
curl -s -o /dev/null -w "%{http_code}" http://app.company.local | grep -q "200" && echo "OK (200)" || echo "FAIL"

echo -n "4. HTTP-запрос к мониторингу Grafana: "
curl -s -o /dev/null -w "%{http_code}" http://grafana.company.local | grep -E -q "200|302" && echo "OK" || echo "FAIL"

echo "=== ТЕСТИРОВАНИЕ ЗАВЕРШЕНО ==="
