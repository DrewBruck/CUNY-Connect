# CUNY Connect
A Capstone Application to assist CUNY students communicate based on classes in schedule

## Todo List:
 - [X] Build Title For Each Conversation
 - [X] Conversations Page
 - [ ] Add + functions.(In Progress)
 - [X] Update profile picture (Initials)
 - [ ] Add Search for all conversations of current user. 
 - [ ] Clean up debug statements
 - [ ] Finalize the README.md


### Flutter
__Compile a dot G File__

```
dart run build_runner build
```


### Deploy our App

__Install Firebase Tools__
```
npm install -g firebase-tools
```

__Initialize Firebase__
```
firebase login
firebase init
```

__Deploy Onto Server__
```
flutter build web
firebase deploy --only hosting
```

> [!IMPORTANT]
> You should atleast v2.2.3 in your hyprland dots (ls ~/.config/hypr) to check version
> You need rsync for it to work
