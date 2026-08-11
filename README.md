# picus

Command-line spaced repetion program

## Install
- You need [janet](https://janet-lang.org/) and [jpm](https://github.com/janet-lang/jpm). Make sure the [spork library](https://github.com/janet-lang/spork) is installed
  ```
  jpm install spork
  ```

- Build picus in `build/picus`
  ```
  jpm build
  ```


## Usage
- See all options
  ```
  build/picus -h
  ```

- Create 10x10 multiplication table 10x10.json

  ```
  build/picus -10x10
  ```

- Teach 2x table of 10x10.json
  ```
  build/picus -t 10x10.json
  ```

- Quiz all due entries of 10x10.json (need to wait 6h after initial teach)
  ```
  build/picus 10x10.json
  ```

