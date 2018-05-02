#!/bin/bash
cd ../GlamCamPaymentFrontend/
npm run build
cp ./build/*.* ../GlamCamBot/Resources/Views/
rm -rf ../GlamCamBot/Public/static
cp -r ./build/static ../GlamCamBot/Public
