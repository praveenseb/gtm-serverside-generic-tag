# GTM Server-Side Generic Tag
## Overview
This is a generic measurement tag template developed for [Google Tag Manager server container](https://developers.google.com/tag-platform/tag-manager/server-side). This template lets you configure a custom measurement pixel on your GTM server container based on Google Analytics (GA4) event data object. The tag is designed to use the built-in GA4 [Client](https://developers.google.com/tag-platform/tag-manager/server-side/intro#how_clients_work) and it is assumed that a Google Analytics (GA4) configuration/event tag is already [sending events](https://developers.google.com/tag-platform/tag-manager/server-side/send-data) to your server container URL. Pixel requests can be generated for all or a sub-set of GA4 events.
## How to use
1. Download the file 'template.tpl'.
2. In your Google Tag Manager web interface, navigate to ‘Templates’ section within your server container.
3. Select ‘New’ and then ‘Import’. Choose the 'template.tpl' file that you downloaded in step 1. Click save.
4. Navigate to ‘Tags’ section and create a new tag using the template you just created.
5. Configure your pixel URL, tracking settings and the URL parameters to be included in the pixel request (HTTP GET).
6. Set a triggering rule to fire the tag when the client name matches your GA4 client name.
7. Save the tag and publish your changes.
8. Validate the tag in preview mode.
## Contributors
[Praveen Sebastian](https://github.com/praveenseb)
## Feedback
Please create an issue in this repo if you have any questions or feedback.
## License
Copyright 2023 Praveen Sebastian

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this software except in compliance with the License.
You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
