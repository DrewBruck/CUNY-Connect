# CUNY Connect
A Capstone Application to assist CUNY students communicate based on classes in schedule

## Todo List:
 - [X] Update Current Firebase Rules (Strict)
 - [ ] Build Title For Each Conversation
 - [ ] Conversations Page
 - [ ] Add + functions.
 - [ ] Add Search for all conversations of current user. 
 - [ ] Update profile picture (Initials)
 - [ ] Update Rules for Conversations (Strict)
 - [ ] Clean up debug statements

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
