# My Dotfiles

---

## FIREFOX

to change the wallpaper in the browser replace the original picture in `chrome/` folder.

Replace the name of the picture in the command, I have <Snow_Ronin.Jpg>

```bash

printf ':root,\nbody {\n background: url("data:image/jpeg;base64,%s") center / cover no-repeat scroll !important;\n}\n' "$(base64 -w0 Snow_Ronin.jpg)" > background.css

```

