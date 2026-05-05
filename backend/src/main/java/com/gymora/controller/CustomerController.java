package com.gymora.controller;

import com.gymora.model.dto.request.CustomerRequest;
import com.gymora.model.dto.response.ApiResponse;
import com.gymora.model.dto.response.CustomerResponse;
import com.gymora.service.CustomerService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/customers")
@RequiredArgsConstructor
@Tag(name = "Customers", description = "Customer management endpoints")
public class CustomerController {

    private final CustomerService customerService;

    @PostMapping
    @PreAuthorize("hasRole('GYM_ADMIN')")
    @Operation(summary = "Register customer")
    public ResponseEntity<ApiResponse<CustomerResponse>> createCustomer(
            @Valid @RequestBody CustomerRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Customer registered", customerService.createCustomer(request)));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get customer by ID")
    public ResponseEntity<ApiResponse<CustomerResponse>> getCustomerById(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.success(customerService.getCustomerById(id)));
    }

    @GetMapping("/user/{userId}")
    @Operation(summary = "Get customer by user ID")
    public ResponseEntity<ApiResponse<CustomerResponse>> getCustomerByUserId(@PathVariable Long userId) {
        return ResponseEntity.ok(ApiResponse.success(customerService.getCustomerByUserId(userId)));
    }

    @GetMapping("/gym/{gymId}")
    @PreAuthorize("hasAnyRole('GYM_ADMIN', 'SUPER_ADMIN')")
    @Operation(summary = "List gym customers")
    public ResponseEntity<ApiResponse<List<CustomerResponse>>> getCustomersByGym(@PathVariable Long gymId) {
        return ResponseEntity.ok(ApiResponse.success(customerService.getCustomersByGym(gymId)));
    }

    @GetMapping("/trainer/{trainerId}")
    @PreAuthorize("hasAnyRole('GYM_ADMIN', 'TRAINER')")
    @Operation(summary = "List trainer's customers")
    public ResponseEntity<ApiResponse<List<CustomerResponse>>> getCustomersByTrainer(
            @PathVariable Long trainerId) {
        return ResponseEntity.ok(ApiResponse.success(customerService.getCustomersByTrainer(trainerId)));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update customer profile")
    public ResponseEntity<ApiResponse<CustomerResponse>> updateCustomer(
            @PathVariable Long id, @RequestBody CustomerRequest request) {
        return ResponseEntity.ok(ApiResponse.success("Customer updated",
                customerService.updateCustomer(id, request)));
    }

    @PatchMapping("/{id}/trainer")
    @PreAuthorize("hasRole('GYM_ADMIN')")
    @Operation(summary = "Assign trainer to customer")
    public ResponseEntity<ApiResponse<CustomerResponse>> assignTrainer(
            @PathVariable Long id, @RequestBody Map<String, Long> request) {
        return ResponseEntity.ok(ApiResponse.success("Trainer assigned",
                customerService.assignTrainer(id, request.get("trainerId"))));
    }
}
