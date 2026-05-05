package com.gymora.controller;

import com.gymora.model.dto.request.PaymentRequest;
import com.gymora.model.dto.response.ApiResponse;
import com.gymora.model.dto.response.PaymentResponse;
import com.gymora.service.PaymentService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/payments")
@RequiredArgsConstructor
@Tag(name = "Payments", description = "Payment management endpoints")
public class PaymentController {

    private final PaymentService paymentService;

    @PostMapping
    @PreAuthorize("hasRole('GYM_ADMIN')")
    @Operation(summary = "Record payment")
    public ResponseEntity<ApiResponse<PaymentResponse>> recordPayment(
            @Valid @RequestBody PaymentRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Payment recorded", paymentService.recordPayment(request)));
    }

    @GetMapping("/customer/{customerId}")
    @Operation(summary = "Get customer payment history")
    public ResponseEntity<ApiResponse<List<PaymentResponse>>> getCustomerPayments(
            @PathVariable Long customerId) {
        return ResponseEntity.ok(ApiResponse.success(paymentService.getCustomerPayments(customerId)));
    }

    @GetMapping("/gym/{gymId}")
    @PreAuthorize("hasRole('GYM_ADMIN')")
    @Operation(summary = "Get gym financial records")
    public ResponseEntity<ApiResponse<List<PaymentResponse>>> getGymPayments(@PathVariable Long gymId) {
        return ResponseEntity.ok(ApiResponse.success(paymentService.getGymPayments(gymId)));
    }
}
