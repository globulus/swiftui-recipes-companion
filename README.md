# SwiftUI Recipes Companion

Companion app and XCode extension for adding SwiftUI recipes to your code.

Choose from a rich selection of SwiftUI recipes, that range from simple tasks to entire custom components:

![Companion App](https://github.com/globulus/swiftui-recipes-companion/blob/main/Images/companionApp.png?raw=true)

Then, simply insert their code straight into yours via the **Editor** menu:

![Companion App](https://github.com/globulus/swiftui-recipes-companion/blob/main/Images/editorExtension.png?raw=true)

## Installation

DOwnload...

Run the **companion app first**. It'll fetch the list of recipes from Github and allow you to preview their content/code and exclude those you don't want in your Editor menu. After you're done, be sure to press the **Save** button.

Then, just run Xcode and find it in **Editor -> Recipes -> ...**. Pressing any recipe command will insert its code at your cursor. There's also the special **Run Companion** command that will start the companion app again.

## Contributing Recipes

All the recipes are open source and live in the [Recipes folder in the Git](https://github.com/globulus/swiftui-recipes-companion/tree/main/Recipes). **Any contributions are more than welcome!**

To contribute a recipe, simply **create a PR with a new recipe file**. A recipe file is a *yml* with the following structure:

```yaml
---
title: "Title of the recipe, as it'll appear in the App/Extension"
description: "Give a short description of the recipe here."
author: "Your name or email address."
url: "Optional, URL to more details on the subject."
image: "Optional, URL to the image accompanying the recipe. Feel free to include the image in the PR."
updatedAt: "ISO-formatted timestamp of the latest recipe update."
minSwiftUIVersion: Minimum SwiftUI version that supports the recipe, e.g 1, 2, 3
maxSwiftUIVersion: Optional, if the recipe got deprecated in a newer SwiftUI version.
---
RECIPE CODE GOES HERE
```

## Blog

Check out [SwiftUIRecipes.com](https://swiftuirecipes.com) for in-depth explanations of common, yet puzzling SwiftUI tasks.