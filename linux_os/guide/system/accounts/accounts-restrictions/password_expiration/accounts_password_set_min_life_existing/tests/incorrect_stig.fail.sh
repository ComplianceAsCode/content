#!/bin/bash

sed -i '/:\(\*\|!!\):/!d' /etc/shadow
echo 'max-test-user:$1$q.YkdxU1$ADmXcU4xwPrM.Pc.dclK81:18648:0:60::::' >> /etc/shadow
