package com.example.demo;

import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@CrossOrigin(origins = "*")   //  FIXES frontend -> backend access
public class HelloController {

    @GetMapping("/hello")
    public String hello() {
        return "Hello from Backend!";
    }

    @GetMapping("/health")
    public String health() {
        return "OK";
    }
}
